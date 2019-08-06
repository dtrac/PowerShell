<#
    .NAME
        LocalSecPol.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure the Local Security Policy
    .AUTHOR
        Dan Tracey
    .DATE
        12 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        12 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration SecPol
{
    Import-DscResource -ModuleName SecurityPolicyDsc

    node localhost
    {
        SecurityOption SecurityOptions
        {
            Name = 'SecurityOptions'
            Microsoft_network_Server_Digitally_sign_communications_always = 'Enabled'
            }
    }
}
