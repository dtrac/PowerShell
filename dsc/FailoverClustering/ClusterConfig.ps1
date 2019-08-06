Configuration 'ClusterConfig' 
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xFailoverCluster

    xClusterDisk Data
    {
        Number = 1
        Ensure = 'Present'
        Label  = 'Data'
    }

    xClusterDisk Logs
    {
        Number = 2
        Ensure = 'Present'
        Label  = 'Logs'
    }

    xClusterDisk Temp
    {
        Number = 3
        Ensure = 'Present'
        Label  = 'Temp'
    }

    xClusterDisk Quorum
    {
        Number = 4
        Ensure = 'Present'
        Label  = 'Quorum'
    }

    xClusterDisk MSDTC
    {
        Number = 5
        Ensure = 'Present'
        Label  = 'MSDTC'
    }
}
