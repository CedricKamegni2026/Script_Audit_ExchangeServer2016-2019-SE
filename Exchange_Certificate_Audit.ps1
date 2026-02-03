
#Liste tous les certificats

#Filtre les certificats non auto-signés

#Indique ceux expirant dans moins de 30 jours

#Exporte le tout dans CSV et TXT


Get-ExchangeCertificate |
    Where { $_.IsSelfSigned -ne $True } |
    Select Thumbprint, Services, NotAfter, Subject, CertificateDomains |
    Export-Csv -NoTypeInformation "C:\Reports\ExchangeCertificates.csv"
