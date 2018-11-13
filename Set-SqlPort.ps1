Write-Verbose -Message 'Reconfiguring SQL Server TCP/IP Port properties...'
Invoke-Command -Session $psSession -ScriptBlock {

    $VerbosePreference  = 'Continue'

    Import-Module sqlps -Verbose:$false

    $wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
    $wmiinstance = $wmi.ServerInstances | Where-Object { $_.Name -eq "$using:sqlInst" }
    $tcp = $wmiinstance.ServerProtocols | Where-Object { $_.DisplayName -eq 'TCP/IP' }
    $IpAddress = $tcp.IpAddresses | where-object { $_.Name -eq 'IPAll' }
    $tcpport = $IpAddress.IpAddressProperties | Where-Object { $_.Name -eq 'TcpPort' }
    $tcpport.Value = '1433'
    $tcp.Alter()

    Restart-Service "MSSQL`$$using:sqlInst" -Force -Verbose

}
