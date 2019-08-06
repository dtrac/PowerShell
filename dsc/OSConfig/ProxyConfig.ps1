<#
    .NAME
        ProxyConfig.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure a proxy server
    .AUTHOR
        Dan Tracey
    .DATE
        11 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        11 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'ProxyConfig'
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName NetworkingDsc

    Node localhost
    {

        ProxySettings ProxyConfig
        {
            IsSingleInstance = 'Yes'
            Ensure = 'Present'
            EnableAutoDetection = $false
            EnableAutoConfiguration = $false
            EnableManualProxy = $true
            ProxyServer = $Node.ProxyServer
        }
    }
}
