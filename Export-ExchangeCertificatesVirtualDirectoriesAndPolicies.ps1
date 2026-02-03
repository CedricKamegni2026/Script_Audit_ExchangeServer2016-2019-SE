#Points clés de ce script

#Indépendant et robuste : chaque bloc est isolé avec try/catch, donc si un export échoue, les autres continuent.

#Exports séparés : un fichier par type de Virtual Directory, un fichier pour chaque type de politique ou règle, et un fichier pour les certificats.

#Lisibilité et maintenance faciles : tu peux ajouter ou retirer des exports très facilement.

#Compatible Exchange 2013 / 2016 / hybride.



# Chemin des exports
$LogPath = "C:\Reports"

# Créer le dossier si nécessaire
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory | Out-Null }

# --------------------------
# Export des certificats Exchange
# --------------------------
try {
    Write-Host "Export des certificats Exchange..." -ForegroundColor Cyan
    Get-ExchangeCertificate |
        Where { $_.IsSelfSigned -eq $False } |
        Select CertificateDomains, Issuer, NotAfter, RootCAType, Services, Status, Subject |
        Out-File "$LogPath\ExchangeCertificate-LocalExchange.txt"
    Write-Host "✔ Export des certificats terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur export certificats : $_" }

# --------------------------
# Export des Virtual Directories
# --------------------------
$VirtualDirs = @(
    @{ Cmd='Get-OwaVirtualDirectory'; File='OWA-VirtualDirectory-LocalExchange.txt' },
    @{ Cmd='Get-PowerShellVirtualDirectory'; File='PowerShellVirtualDirectory-LocalExchange.txt' },
    @{ Cmd='Get-ActiveSyncVirtualDirectory'; File='ActiveSyncVirtualDirectory-LocalExchange.txt' },
    @{ Cmd='Get-WebServicesVirtualDirectory'; File='WebServicesVirtualDirectory-LocalExchange.txt' },
    @{ Cmd='Get-OabVirtualDirectory'; File='OABVirtualDirectory-LocalExchange.txt' }
)

foreach ($vd in $VirtualDirs) {
    try {
        Write-Host "Export de $($vd.Cmd)..." -ForegroundColor Cyan
        & $vd.Cmd | Select Name, Server, InternalURL, ExternalURL | Format-List | Out-File "$LogPath\$($vd.File)"
        Write-Host "✔ Export $($vd.Cmd) terminé" -ForegroundColor Green
    } catch { Write-Warning "Erreur $($vd.Cmd) : $_" }
}

# --------------------------
# Export des politiques et règles
# --------------------------
try {
    Write-Host "Export OWA Mailbox Policies..." -ForegroundColor Cyan
    Get-OwaMailboxPolicy | Select * | Out-File "$LogPath\OWAMailboxPolicies-LocalExchange.txt"
    Write-Host "✔ Export OWA Mailbox Policies terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur OWA Mailbox Policies : $_" }

try {
    Write-Host "Export Mobile Device Mailbox Policies..." -ForegroundColor Cyan
    Get-MobileDeviceMailboxPolicy | Select * | Out-File "$LogPath\MobileDevicePolicies-LocalExchange.txt"
    Write-Host "✔ Export Mobile Device Policies terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Mobile Device Policies : $_" }

try {
    Write-Host "Export Transport Rules..." -ForegroundColor Cyan
    Get-TransportRule | Select Name, Priority, Description, Comments, State | Out-File "$LogPath\TransportRules-LocalExchange.txt"
    Write-Host "✔ Export Transport Rules terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Transport Rules : $_" }

try {
    Write-Host "Export Email Address Policies..." -ForegroundColor Cyan
    Get-EmailAddressPolicy | Select Name, Priority, RecipientFilter, RecipientFilterApplied, IncludeRecipients, EnabledPrimarySMTPAddressTemplate, EnabledEmailAddressTemplates, Enabled, IsValid | Out-File "$LogPath\EmailAddressPolicy-LocalExchange.txt"
    Write-Host "✔ Export Email Address Policies terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Email Address Policy : $_" }
