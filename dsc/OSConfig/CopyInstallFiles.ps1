<#
    .NAME
        CopyInstallFiles.ps1
    .SYNOPSIS
        Uses PowerShell DSC to copy installation files locally 
    .AUTHOR
        Dan Tracey
    .DATE
        12 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        12 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'CopyInstallFiles'
    {
        Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$BuildCreds
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node localhost
        {

            File CopyInstallFiles
            {
                DestinationPath = $Node.InstallDir
                SourcePath      = $Node.SourceFiles
                Ensure          = "Present"
                Type            = "Directory"
                Recurse         = $true
                Credential      = $BuildCreds
            }
        }
    }
