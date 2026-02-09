#pour que celà fonctionne il faut modifier la stratégie d'adresse en la desactivant, pour desactiver voir le lien : 
#https://www.alitajran.com/automatically-update-email-addresses-based-on-email-address-policy/

#lien qui a servi à generer le script : https://smtpbd.com/how-to-change-primary-smtp-address-in-exchange-2016-powershell/

#Considérations importantes
#Alias d'e-mail : la modification de l'adresse SMTP principale ne supprime pas les alias existants. Les utilisateurs peuvent toujours recevoir des e-mails à leurs anciennes adresses, sauf si vous supprimez ces alias.
#Service Autodiscover : si vous utilisez Autodiscover, assurez-vous que le nouveau domaine SMTP est enregistré et correctement configuré.
#Notification des utilisateurs : informez les utilisateurs de la modification, en particulier s'ils doivent mettre à jour leurs informations de connexion ou les configurations de messagerie sur leurs appareils.


# Chemin vers le fichier CSV
$CsvPath = "C:\Path\To\emails.csv"

# Chemin du fichier de log
$LogPath = "C:\Path\To\MailboxUpdateLog.txt"

# Initialisation du fichier log
"--- Début du script $(Get-Date) ---" | Out-File -FilePath $LogPath -Encoding UTF8

# Vérifie si le fichier CSV existe
if (-Not (Test-Path -Path $CsvPath)) {
    $msg = "ERREUR : Le fichier CSV '$CsvPath' n'existe pas."
    Write-Host $msg -ForegroundColor Red
    $msg | Out-File -FilePath $LogPath -Append -Encoding UTF8
    return
}

# Importation du CSV et traitement ligne par ligne
Import-Csv -Path $CsvPath | ForEach-Object {
    try {
        # Message d'action
        $actionMsg = "Mise à jour de la boîte mail : $($_.UserName) → $($_.NewPrimarySMTP)"
        Write-Host $actionMsg -ForegroundColor Cyan
        $actionMsg | Out-File -FilePath $LogPath -Append -Encoding UTF8

        # Exécution de la modification
        Set-Mailbox -Identity $_.UserName -PrimarySmtpAddress $_.NewPrimarySMTP -ErrorAction Stop

        # Succès
        $successMsg = "✅ Mise à jour réussie pour $($_.UserName)"
        Write-Host $successMsg -ForegroundColor Green
        $successMsg | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
    catch {
        # Gestion de l'erreur
        $errorMsg = "⚠️ ERREUR pour $($_.UserName) : $_"
        Write-Host $errorMsg -ForegroundColor Red
        $errorMsg | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
}

"--- Fin du script $(Get-Date) ---" | Out-File -FilePath $LogPath -Append -Encoding UTF8
