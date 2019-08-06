$scriptPath =  $OctopusParameters['ScriptPath']
$dscConfigName = 'FailoverClustering'
$secPass = ConvertTo-SecureString -String $OctopusParameters['DomainAdminPass'] -AsPlainText -Force
$DomainAdminCreds = New-Object System.Management.Automation.PSCredential($OctopusParameters['DomainAdminUser'],$secPass)

function ClearDscConfig {
    
    Remove-DscConfigurationDocument -Stage Pending -Force
    Remove-DscConfigurationDocument -Stage Current -Force
    
}
ClearDscConfig

. $scriptPath\$($dscConfigName).ps1 ; $dscConfigName -ConfigurationData $scriptPath\ConfigurationData.psd1 -DomainAdminCreds $DomainAdminCreds -OutputPath $scriptPath\$dscConfigName
Start-DscConfiguration -Path $scriptPath\$dscConfigName -ComputerName localhost -Force -Wait -Verbose ; ClearDscConfig
