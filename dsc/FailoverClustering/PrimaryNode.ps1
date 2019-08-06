Configuration 'PrimaryNode'
{
    param(
    [Parameter(Mandatory = $true)]
    [PSCredential]
    $DomainAdminCreds
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xFailOverCluster

    Node localhost
    {
        WindowsFeatureSet FailoverClustering
        {
            Name             = $Node.ClusteringComponents
            Ensure           = "Present"
        }

        xCluster CreateCluster
        {
            Name                          = $Node.ClusterName
            StaticIPAddress               = $Node.ClusterIp
            DomainAdministratorCredential = $DomainAdminCreds
            DependsOn                     = '[WindowsFeatureSet]FailoverClustering'
        }
    }
}
