<#
    .NAME
        EnterpriseLibraryInstall.ps1
    .SYNOPSIS
        Uses PowerShell DSC to Install Microsoft Enterprise Library 5
    .AUTHOR
        Dan Tracey
    .DATE
        30 / 05 /2019
    .VERSION
        0.1
    .CHANGELOG
        30 / 05 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'EnterpriseLibraryInstall'
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
    {

        Package EnterpriseLibraryInstall
        {
            Ensure          = 'Present'
            Name            = "Microsoft Enterprise Library 5.0"
            Path            = $Node.EnterpriseLibraryFiles
            ProductId       = $Node.EnterpriseLibraryProductId
            Arguments       = "/quiet /norestart  /L*v C:\Install\Logs\EnterpriseLibrary_install.log"
        }
    }
}
