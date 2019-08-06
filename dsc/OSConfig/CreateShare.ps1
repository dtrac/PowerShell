<#
    .NAME
        CreateShare.ps1
    .SYNOPSIS
        Uses PowerShell DSC to create and share the DAS Scheduler folder
    .AUTHOR
        Dan Tracey
    .DATE
        11 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        11 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'CreateShare'
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare

    Node localhost
    {

        File CreateFolder
        {
            DestinationPath = "C:\Folder"
            Type            = "Directory"
            Ensure          = "Present"
        }

        xSmbShare ShareFolder
        {
            Ensure          = 'Present'
            Name            = 'Folder'
            Path            = "C:\Folder"
            ChangeAccess    = 'Everyone'
            DependsOn       = "[File]CreateFolder"

        }
    }
}
