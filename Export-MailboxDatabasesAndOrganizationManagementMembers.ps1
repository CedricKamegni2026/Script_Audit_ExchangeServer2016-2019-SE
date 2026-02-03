#Tout-en-un : une seule exécution pour récupérer les deux types d’informations.

#Sécurité : try/catch pour que si l’une des commandes échoue, l’autre continue.

#Fichiers séparés pour la clarté :

##MailboxDatabaseConfigs-LocalExchange.txt

#ExchangeAdmins-LocalExchange.txt


# Chemin des exports
$LogPath = "C:\Reports"

# Créer le dossier si nécessaire
if (!(Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory | Out-Null
}

# --------------------------
# Export des Mailbox Databases
# --------------------------
try {
    Write-Host "Export des Mailbox Databases..." -ForegroundColor Cyan
    Get-MailboxDatabase | Select * | Out-File "$LogPath\MailboxDatabaseConfigs-LocalExchange.txt"
    Write-Host "✔ Export Mailbox Databases terminé" -ForegroundColor Green
} catch {
    Write-Warning "Erreur export Mailbox Databases : $_"
}

# --------------------------
# Export des membres du groupe Organization Management
# --------------------------
try {
    Write-Host "Export des membres du groupe Organization Management..." -ForegroundColor Cyan
    Get-RoleGroupMember "Organization Management" | Out-File "$LogPath\ExchangeAdmins-LocalExchange.txt"
    Write-Host "✔ Export Organization Management Members terminé" -ForegroundColor Green
} catch {
    Write-Warning "Erreur export Organization Management Members : $_"
}
