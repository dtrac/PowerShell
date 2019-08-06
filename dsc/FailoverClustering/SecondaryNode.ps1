Configuration 'SecondaryNode'
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

        xWaitForCluster WaitForCluster
        {
            Name             = $Node.ClusterName
            RetryIntervalSec = 10
            RetryCount       = 60
            DependsOn        = '[WindowsFeatureSet]FailoverClustering'
        }

        xCluster JoinSecondNodeToCluster
        {
            Name                          = $Node.ClusterName
            StaticIPAddress               = $Node.ClusterIp
            DomainAdministratorCredential = $DomainAdminCreds
            DependsOn                     = '[xWaitForCluster]WaitForCluster'
        }      
    }
}
