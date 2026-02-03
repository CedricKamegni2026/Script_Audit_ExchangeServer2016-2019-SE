#Crée un dossier pour les rapports si nécessaire (C:\Reports).

#Récupère toutes les boîtes aux lettres.

#Exporte Send-As, Send on Behalf, et Full Access dans des fichiers CSV séparés.

#Chaque bloc est indépendant, donc si une commande échoue, les autres s’exécutent toujours.



# Chemin pour les exports
$LogPath = "C:\Reports"

# Créer le dossier s'il n'existe pas
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory | Out-Null }

# Récupération de toutes les boîtes aux lettres
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# --------------------------
# Send-As
# --------------------------
try {
    Write-Host "Export Send-As en cours..." -ForegroundColor Cyan

    $Mailboxes | Get-ADPermission |
        Where { ($_.ExtendedRights -like "*Send-As*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } |
        Select Identity, User, RecipientTypeDetails |
        Export-Csv -NoTypeInformation "$LogPath\MailboxSendAsAccess.csv"

    Write-Host "✔ Export Send-As terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Send-As : $_" }

# --------------------------
# Send on Behalf
# --------------------------
try {
    Write-Host "Export Send on Behalf en cours..." -ForegroundColor Cyan

    $Mailboxes | Where-Object {$_.GrantSendOnBehalfTo} |
        Select Name,@{Name='GrantSendOnBehalfTo';Expression={($_ | Select -ExpandProperty GrantSendOnBehalfTo | Select -ExpandProperty Name) -join ","}} |
        Export-Csv -NoTypeInformation "$LogPath\MailboxSendOnBehalf.csv"

    Write-Host "✔ Export Send on Behalf terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Send on Behalf : $_" }

# --------------------------
# Full Access
# --------------------------
try {
    Write-Host "Export Full Access en cours..." -ForegroundColor Cyan

    $Mailboxes | Get-MailboxPermission |
        Where { ($_.IsInherited -eq $False) -and -not ($_.User -like "NT AUTHORITY\SELF") -and -not ($_.User -like '*Discovery Management*') } |
        Select Identity, User, RecipientTypeDetails |
        Export-Csv -NoTypeInformation "$LogPath\MailboxFullAccess.csv"

    Write-Host "✔ Export Full Access terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Full Access : $_" }
