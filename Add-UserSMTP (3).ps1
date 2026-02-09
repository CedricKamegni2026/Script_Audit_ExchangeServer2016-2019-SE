<#
.Synopsis
   Ajoute une ou plusieurs adresses SMTP à des utilisateurs Active Directory depuis un CSV.
.Description
   Ce script lit un fichier CSV contenant les utilisateurs et les adresses SMTP à ajouter.
   Il vérifie si l'adresse existe déjà avant de l'ajouter et supporte les adresses principales ou secondaires.

   FORMAT DU CSV :
   user,emailid
   ku0f1999,kunal.udapi@vcloud-lab.com
   md0f2011,mahesh.deshmukh@vcloud-lab.com

   NB : La colonne "user" correspond au SamAccountName de l'utilisateur dans Active Directory.
.Param CSVFile
   Chemin complet vers le fichier CSV contenant les utilisateurs et leurs adresses.
.Param Primary
   Si activé, l'adresse sera ajoutée comme SMTP principale (majuscule). Sinon, secondaire (minuscule).
.Param LogFile
   Chemin complet pour le fichier de log.
.Param WhatIf
   Simule l'exécution sans apporter de modifications à Active Directory.
.Example
   ./Add-UserSMTP.ps1 -CSVFile "C:\Temp\users.csv" -Primary:$false -LogFile "C:\Temp\AddUserSMTP.log"
   
   Plan exacution Sxript: 
   # Ajouter des adresses secondaires (smtp)
.\Add-UserSMTP.ps1 -CSVFile "C:\Temp\users.csv" -LogFile "C:\Temp\AddUserSMTP.log"

# Ajouter une adresse principale (SMTP)
.\Add-UserSMTP.ps1 -CSVFile "C:\Temp\users.csv" -Primary -LogFile "C:\Temp\AddUserSMTP.log"

# Simulation sans modification
.\Add-UserSMTP.ps1 -CSVFile "C:\Temp\users.csv" -WhatIf -LogFile "C:\Temp\AddUserSMTP.log"

   
   
   
   

.Notes
   Nom : Add-UserSMTP
   Auteur : Cédric KAMEGNI
   Création : 01 Février 2026
   Version : 1.0
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    [string]$CSVFile,

    [Parameter()]
    [switch]$Primary,

    [Parameter()]
    [string]$LogFile = "C:\Temp\AddUserSMTP.log"
)

# Vérifier l’existence du fichier CSV
if (-not (Test-Path $CSVFile)) {
    Write-Host "Fichier CSV introuvable : $CSVFile" -ForegroundColor Red
    exit
}

# Importer le module Active Directory
Import-Module ActiveDirectory -ErrorAction Stop

# Importer les utilisateurs depuis le CSV
$users = Import-Csv -Path $CSVFile

# Variables pour le résumé final
$addedCount = 0
$existsCount = 0
$errorCount = 0

# Créer / vider le fichier de log
if (Test-Path $LogFile) { Remove-Item $LogFile }
Add-Content $LogFile "=== Script Add-UserSMTP log - $(Get-Date) ===`r`n"

foreach ($u in $users) {
    # Vérifier que les colonnes existent
    if (-not ($u.PSObject.Properties.Match('user') -and $u.PSObject.Properties.Match('emailid'))) {
        Write-Host "CSV invalide : ligne ignorée" -ForegroundColor Yellow
        Add-Content $LogFile "CSV invalide pour ligne : $($u | Out-String)"
        continue
    }

    Try {
        $user = Get-ADUser -Identity $u.user -Properties ProxyAddresses -ErrorAction Stop
        $prefix = if ($Primary) { "SMTP:" } else { "smtp:" }
        $newSMTP = "$prefix$($u.emailid)"

        if ($user.ProxyAddresses -notcontains $newSMTP) {
            if ($PSCmdlet.ShouldProcess($u.user, "Ajouter $newSMTP")) {
                Set-ADUser -Identity $u.user -Add @{ProxyAddresses=$newSMTP} -ErrorAction Stop
            }
            Write-Host "Adresse ajoutée pour $($u.user) : $newSMTP" -ForegroundColor Green
            Add-Content $LogFile "$(Get-Date) - Ajouté : $newSMTP pour $($u.user)"
            $addedCount++
        } else {
            Write-Host "Adresse déjà présente pour $($u.user) : $newSMTP" -ForegroundColor Yellow
            Add-Content $LogFile "$(Get-Date) - Déjà existante : $newSMTP pour $($u.user)"
            $existsCount++
        }
    } Catch {
        Write-Host "Erreur pour l'utilisateur : $($u.user)" -ForegroundColor Red
        Add-Content $LogFile "$(Get-Date) - ERREUR pour $($u.user) : $_"
        $errorCount++
    }
}

# Résumé final
Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
Write-Host "✅ Adresses ajoutées    : $addedCount" -ForegroundColor Green
Write-Host "⚠️ Adresses existantes  : $existsCount" -ForegroundColor Yellow
Write-Host "❌ Erreurs              : $errorCount" -ForegroundColor Red
Add-Content $LogFile "`n=== Résumé ==="
Add-Content $LogFile "Ajouts    : $addedCount"
Add-Content $LogFile "Existantes: $existsCount"
Add-Content $LogFile "Erreurs   : $errorCount"

Write-Host "`nScript terminé ! Fichier log : $LogFile" -ForegroundColor Cyan
