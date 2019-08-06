<#
    .NAME
        WebServer.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure a Certify Web Server 
    .AUTHOR
        Dan Tracey
    .DATE
        03 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        03 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'WebServer'
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
    {
        WindowsFeatureSet WebServer
        {
            Name             = $Node.WebComponents
            Ensure           = "Present"
            Source           = $Node.SxsSource
        }                  
    }
}
