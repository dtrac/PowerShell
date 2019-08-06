<#
    .NAME
        HostsFile.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure a local Hosts file 
    .AUTHOR
        Dan Tracey
    .DATE
        28 / 05 /2019
    .EXAMPLE
        Expects Configuration file syntax:
        HostsEntries = "host1.fqdn:1.1.1.1","host2.fqdn:1.1.1.2"
    .VERSION
        0.1
    .CHANGELOG
        28 / 05 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration HostsFile
{
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    Import-DSCResource -ModuleName 'NetworkingDsc'

    Node localhost
    {
        $arr = @($Node.HostsEntries)

        foreach ($item in $arr){

            $hostname = $item.split(":")[0]
            $ip = $item.split(":")[1]

            HostsFile $hostname
            {
                HostName  = $hostname
                IPAddress = $ip
                Ensure    = 'Present'
            }
       }
    }
}
