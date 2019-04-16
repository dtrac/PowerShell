<#
    .NAME
        AdPreReqsConfiguration.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure AD Pre-Reqs
    .AUTHOR
        Dan Tracey
    .DATE
        05 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        05 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'AdPreReqs'
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName xPendingReboot

    Node localhost
                
    {

        $Interface = Get-NetAdapter -Name "Ethernet*" | Sort-Object -Property ifIndex | Select-Object -First 1

        NetIPInterface DisableDhcp
        {
            InterfaceAlias = $Interface.InterfaceAlias # 'Ethernet0'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
        }

        IPAddress NewIPv4Address
        {
            IPAddress      = $Node.IPConfig
            InterfaceAlias = $Interface.InterfaceAlias # 'Ethernet0'
            AddressFamily  = 'IPv4'

        }

        DefaultGatewayAddress SetDefaultGateway
        {
            Address        = $Node.DefaultGateway
            InterfaceAlias = $Interface.InterfaceAlias # 'Ethernet0'
            AddressFamily  = 'IPv4'

        }
            
        DnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $Interface.InterfaceAlias # 'Ethernet0'
            AddressFamily  = 'IPv4'
        }

        WindowsFeatureSet WindowsFeatures 
        {
            Name = $Node.WindowsFeatures
            Ensure = 'Present'
        }

        xPendingReboot RebootCheck
        {
            Name = "Test for reboot"
            SkipCcmClientSDK = $true
        }

        Computer RenameComputer
        {
            Name = $Node.Hostname
        }

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }
    }
}
