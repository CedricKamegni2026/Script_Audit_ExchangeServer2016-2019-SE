#Indépendant et robuste : si une commande échoue, les autres continuent.

#Exports séparés : 3 fichiers CSV distincts → plus simple à analyser.

#Facile à modifier : tu peux changer $LogPath pour un autre dossier.


# Chemin des exports
$LogPath = "C:\Reports"

# Créer le dossier si nécessaire
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory | Out-Null }

# Récupérer toutes les boîtes aux lettres
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# --------------------------
# Statistiques des boîtes aux lettres
# --------------------------
try {
    Write-Host "Export des statistiques des boîtes aux lettres..." -ForegroundColor Cyan

    $MailboxStats = $Mailboxes | Group-Object RecipientTypeDetails | Select Count, Name
    $MailboxStats | Export-Csv -NoTypeInformation "$LogPath\MailboxStats.csv"

    Write-Host "✔ Statistiques exportées" -ForegroundColor Green
} catch { Write-Warning "Erreur export Statistiques : $_" }

# --------------------------
# Détails des boîtes aux lettres
# --------------------------
try {
    Write-Host "Export des détails des boîtes aux lettres..." -ForegroundColor Cyan

    $Mailboxes | Select DisplayName, Alias, PrimarySMTPAddress, Database |
        Export-Csv -NoTypeInformation "$LogPath\MailboxDetails.csv"

    Write-Host "✔ Détails exportés" -ForegroundColor Green
} catch { Write-Warning "Erreur export Détails : $_" }

# --------------------------
# Boîtes aux lettres avec redirection
# --------------------------
try {
    Write-Host "Export des boîtes aux lettres avec redirection..." -ForegroundColor Cyan

    $Mailboxes | Where {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} |
        Select Name, DisplayName, PrimarySMTPAddress, UserPrincipalName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward |
        Export-Csv -NoTypeInformation "$LogPath\MailboxesWithForwarding.csv"

    Write-Host "✔ Boîtes avec redirection exportées" -ForegroundColor Green
} catch { Write-Warning "Erreur export Redirection : $_" }
