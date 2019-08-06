@{
  AllNodes = @(
      @{

        NodeName                  =    'localhost'

        # OS Configuration
        LocalAdmins               =    'DOMAIN\DBA_Team'
        ClusteringComponents      =    'Failover-Clustering','RSAT-Clustering','RSAT-Clustering-PowerShell','RSAT-Clustering-CmdInterface'

        # Cluster Configuration
        ClusterName               = 'DEV-DT-SQLCLU'
        ClusterIp                 = '10.1.1.3/24'
        DiskConfiguration = @(
                      @{
                        Number = 1
                        Label = 'Data'
                        Letter = 'D'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount = 60
                       }
                       @{
                        Number = 2
                        Label = 'Logs'
                        Letter = 'L'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount = 60
                       }
                       @{
                        Number = 3
                        Label = 'Temp'
                        Letter = 'T'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount = 60
                       }
                       @{
                        Number = 4
                        Label = 'Quorum'
                        Letter = 'Q'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount = 60
                       }
                       @{
                        Number = 5
                        Label = 'MSDTC'
                        Letter = 'M'
                        Format = 'NTFS'
                        RetryInterval = 60
                        RetryCount = 60
                       }
                     )

        # DSC Config
        PSDscAllowPlainTextPassword = $true
        PSDscAllowDomainUser        = $true

      }
  )
}
