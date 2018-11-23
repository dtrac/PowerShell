<#
.NAME
	Set-DscClient.ps1
.SYNOPSIS
	Uses PowerShell to download and import the DSC private key certificate for credential decryption, and onboard the node for DSC.
.AUTHOR
	Dan Tracey
.DATE
	12 / 09 / 2018
.VERSION
	1.0
.CHANGELOG
    12 / 09 / 2018 - v1.0 - Initial Script (DanT).
#>

# Variables
[CmdletBinding()]
param(
  [string]$hostName,
  [string]$adminUser,
  [securestring]$adminPassword,
  [string]$certPassword,
  [string]$RegistrationKey,
  [string]$ServerName,
  [string]$CertificateId

)
$url = <REDACTED>
$VerbosePreference = 'Continue'

Write-Verbose -Message 'Importing PSInfraHosting PowerShell Module...'
    $VerbosePreference = 'SilentlyContinue'
    Import-Module PSInfraHosting
    $VerbosePreference = 'Continue'

Write-Verbose -Message "Connecting PS Session to $hostname..."
    $psSession = Connect-PSRemoteSession -hostname $hostname -adminUser $adminUser -adminPassword $adminPassword
    $psSession

Invoke-Command -Session $psSession -ScriptBlock {

    $VerbosePreference = 'Continue'

    Write-Verbose -Message 'Downloading Dsc Certificate...'
		    (New-Object System.Net.WebClient).DownloadFile($url,"$env:TEMP\DscPrivateKey.pfx")

    Write-Verbose -Message 'Importing Dsc Certificate...'
            $mypwd = ConvertTo-SecureString -String $using:CertPassword -Force -AsPlainText
            Import-PfxCertificate -FilePath "$env:temp\DscPrivateKey.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd > $null

    Write-Verbose -Message 'Configuring WinRM for DSC...'
    if (!((Test-NetConnection localhost -port 5985 -Verbose:$false).TcpTestSucceeded)){
            New-Item -Path WSMan:\LocalHost\Listener -Transport HTTP -Address * -Force
        }
        else{
            Write-Verbose -Message "HTTP Listener already exists!"
        }

    Write-Verbose -Message 'Returning Dsc Certificate Thumbprint...'
    $thumbprint = (Get-Childitem –Path Cert:\LocalMachine\My | Where {$_.Subject -eq 'CN=DscEncryptionCert'}).Thumbprint
    $thumbprint

}

$content = "
[DSCLocalConfigurationManager()]
configuration ConfigurationRegisterWithPullServer
{
    Node localhost
    {
        Settings
        {
            RefreshMode        = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = `$true
            CertificateID = `"$CertificateId`"
            ConfigurationMode  = 'ApplyAndMonitor'
        }

        ConfigurationRepositoryWeb PullSrv
        {
            ServerURL          = `"http://$ServerName`:8080/PSDSCPullServer.svc`"
            RegistrationKey    = `"$RegistrationKey`"
            ConfigurationNames = @(`$env:COMPUTERNAME)
            AllowUnsecureConnection = `$true
        }
    }
}
"

Invoke-Command -Session $psSession -ScriptBlock {

    $VerbosePreference = 'Continue'

    if (!(Test-Path C:\Temp)){New-Item -ItemType Directory C:\Temp}
    Set-Content -Value $using:content -Path C:\Temp\ConfigurationRegisterWithPullServer.ps1
    . C:\Temp\ConfigurationRegisterWithPullServer.ps1
    Set-Location C:\Temp
    ConfigurationRegisterWithPullServer -OutputPath C:\Temp\RegisterWithPullServer
    Set-DscLocalConfigurationManager localhost -Path C:\Temp\RegisterWithPullServer -Verbose
}

Invoke-Command -Session $psSession -ScriptBlock {
    $VerbosePreference = 'Continue'
    Get-DscLocalConfigurationManager
    Update-DscConfiguration -Wait
    Get-DscConfigurationStatus
}

# Clean up
Invoke-Command -Session $psSession -ScriptBlock {
    $VerbosePreference = 'Continue'
    Remove-Item -Path C:\Temp\RegisterWithPullServer -Verbose -Recurse
}
Write-Verbose -Message "Disconnecting PS Session from $hostname..."
$psSession | Remove-PSSession

Write-Verbose -Message 'Script Complete'
#End
