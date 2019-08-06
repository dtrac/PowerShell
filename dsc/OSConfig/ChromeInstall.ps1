<#
    .NAME
        ChromeInstall.ps1
    .SYNOPSIS
        Uses PowerShell DSC to install Google Chrome
    .AUTHOR
        Dan Tracey
    .DATE
        17 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        17 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'ChromeInstall'
    {

        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node localhost
        {
            Package InstallChrome
            {
                Name            = "Google Chrome"
                Path            = $Node.ChromeInstallFiles
                ProductId       = $Node.ChromeProductId
            }

            LocalConfigurationManager
            {
                RebootNodeIfNeeded = $false
            }
        }
    }
