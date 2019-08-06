<#
    .NAME
        AddToLocalAdmins.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure Admins for the Certify App Server
    .AUTHOR
        Dan Tracey
    .DATE
        30 / 05 / 2019
    .VERSION
        0.1
    .CHANGELOG
        30 / 05 / 2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'AddToLocalAdmins'
{
    Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]$BuildCreds

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost
    {
        foreach ($item in $Node.AppServerAdmins){

            xGroupSet $item
            {
                GroupName            = "Administrators"
                MembersToInclude     = $item
                Credential           = $BuildCreds
            }
        }
    }
}
