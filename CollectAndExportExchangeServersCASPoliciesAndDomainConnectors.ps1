#Chaque bloc est indépendant avec try/catch, donc si une commande échoue, les autres continuent.

#Chaque type de données est exporté dans un fichier séparé, facile à analyser.

#Compatible Exchange 2013, 2016, et Exchange Online hybride.

#Lisibilité maximale : le script est structuré en sections Serveurs/CAS, Politiques/Règles, Domaines/Connecteurs



# Chemin des exports
$LogPath = "C:\Reports"

# Créer le dossier si nécessaire
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory | Out-Null }

# --------------------------
# Export des serveurs Exchange et Client Access Servers (CAS)
# --------------------------
try {
    Write-Host "Export des Client Access Servers (CAS)..." -ForegroundColor Cyan
    Get-ClientAccessServer | Select Name, AutoDiscoverServiceCN, AutoDiscoverServiceInternalUri, OutlookAnywhereEnabled | Format-List |
        Out-File "$LogPath\AutoDiscoverSCPandOutlookAnywhere-LocalExchange.txt"
    Write-Host "✔ Export CAS terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur export CAS : $_" }

try {
    Write-Host "Export des serveurs Exchange..." -ForegroundColor Cyan
    Get-ExchangeServer | Select Name, Server, Domain, FQDN, ServerRole, IsMemberOfCluster, AdminDisplayVersion |
        Out-File "$LogPath\ExchangeServer-LocalExchange.txt"
    Write-Host "✔ Export Exchange Servers terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur export Exchange Servers : $_" }

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
    Get-EmailAddressPolicy | Select Name, Priority, RecipientFilter, RecipientFilterApplied, IncludeRecipients, EnabledPrimarySMTPAddressTemplate, EnabledEmailAddressTemplates, Enabled, IsValid |
        Out-File "$LogPath\EmailAddressPolicy-LocalExchange.txt"
    Write-Host "✔ Export Email Address Policies terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Email Address Policy : $_" }

# --------------------------
# Export des domaines et connecteurs
# --------------------------
try {
    Write-Host "Export des domaines acceptés..." -ForegroundColor Cyan
    Get-AcceptedDomain | Select Name, DomainName, DomainType, Default |
        Out-File "$LogPath\AcceptedDomains-LocalExchange.txt"
    Write-Host "✔ Export Accepted Domains terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Accepted Domains : $_" }

try {
    Write-Host "Export des Receive Connectors..." -ForegroundColor Cyan
    Get-ReceiveConnector | Select Name, Enabled, ProtocolLoggingLevel, FQDN, MaxMessageSize, Bindings, RemoteIPRanges, AuthMechanism, PermissionGroups |
        Out-File "$LogPath\ReceiveConnectors-LocalExchange.txt"
    Write-Host "✔ Export Receive Connectors terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Receive Connectors : $_" }

try {
    Write-Host "Export des Send Connectors..." -ForegroundColor Cyan
    Get-SendConnector | Select Name, Enabled, ProtocolLoggingLevel, SmartHostsString, FQDN, MaxMessageSize, AddressSpaces, SourceTransportServers |
        Out-File "$LogPath\SendConnectors-LocalExchange.txt"
    Write-Host "✔ Export Send Connectors terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Send Connectors : $_" }

try {
    Write-Host "Export de la configuration Transport Service..." -ForegroundColor Cyan
    Get-TransportService | Select * | Out-File "$LogPath\TransportConfiguration-LocalExchange.txt"
    Write-Host "✔ Export Transport Service terminé" -ForegroundColor Green
} catch { Write-Warning "Erreur Transport Service : $_" }
