<#
    .NAME
        DomainJoin.ps1
    .SYNOPSIS
        Uses PowerShell DSC to join an AD domain
    .AUTHOR
        Dan Tracey
    .DATE
        08 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        08 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

#Requires -module ComputerManagementDsc
#Requires -module NetworkingDsc


Configuration DomainJoin
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$DomainJoinCreds
    )

    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module NetworkingDsc

    Node localhost
    {
        $Interface = Get-NetAdapter -Name "Ethernet*" | Sort-Object -Property ifIndex | Select-Object -First 1

        DnsServerAddress DnsServerAddress
        {
            Address        = $Node.DNSServer
            InterfaceAlias = $Interface.InterfaceAlias # 'Ethernet0'
            AddressFamily  = 'IPv4'
        }

        Computer JoinDomain
        {
            Name       = $Node.Hostname
            DomainName = $Node.DomainDnsName
            Credential = $DomainJoinCreds # Credential to join to domain
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
    }
}
