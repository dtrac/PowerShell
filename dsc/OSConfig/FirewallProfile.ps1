<#
    .NAME
        FirewallProfile.ps1
    .SYNOPSIS
        Uses PowerShell DSC to disable Windows Firewall
    .AUTHOR
        Dan Tracey
    .DATE
        10 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        10 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

#Requires -module NetworkingDsc

Configuration FirewallProfile
{
    Import-DscResource -Module NetworkingDsc

    Node localhost
    {
        FirewallProfile ConfigurePrivateFirewallProfile
        {
            Name = 'Private'
            Enabled = 'False'
        }

        FirewallProfile ConfigurePublicFirewallProfile
        {
            Name = 'Public'
            Enabled = 'False'
        }

        FirewallProfile ConfigureDomainFirewallProfile
        {
            Name = 'Domain'
            Enabled = 'False'
        }
    }
}
