<#
    .NAME
        DomainControllerConfiguration.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure a Domain Controller
    .AUTHOR
        Dan Tracey
    .DATE
        05 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        05 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'DomainController'
{
    Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]$DomainAdminCreds,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]$SafeModeCreds
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory

    Node localhost
                
    {

        xADDomain DC
        {
            DomainName = $Node.DomainDnsName
            DomainNetBiosName = $Node.DomainName
            DomainAdministratorCredential = $DomainAdminCreds
            SafemodeAdministratorPassword = $SafeModeCreds
            DatabasePath = 'C:\NTDS'
            LogPath = 'C:\NTDS'
           
        }
    }
}
