function Export-CertChain { 
    Param(
    [string]$SubjectToMatch
    )

   $cert = Get-ChildItem -path cert:\LocalMachine\Root | Where {$_.Subject -match $SubjectToMatch}
   $issuer = $cert.Issuer
   
   if ($cert.subject -eq $issuer){
        Export-Certificate -Cert $cert -FilePath "$scriptPath\$($Cert.Subject.Split(",")[0].Replace("CN=",'')).cer" -Force -Confirm:$false
   }
   else {
        Export-Certificate -Cert $cert -FilePath "$scriptPath\$($Cert.Subject.Split(",")[0].Replace("CN=",'')).cer" -Force -Confirm:$false
        Export-CertChain -SubjectToMatch $issuer
   }
}

$InitialSubjectToMatch = "test" 
Export-CertChain -SubjectToMatch $InitialSubjectToMatch
