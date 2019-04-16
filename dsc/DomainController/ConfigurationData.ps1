@{
    AllNodes = @(
        @{

          NodeName = 'localhost'
          
          # OS Configuration
          
          WindowsFeatures = 'AD-Domain-Services','RSAT-AD-AdminCenter','DNS','RSAT-DNS-SERVER'
          IPConfig        = '10.0.2.100/24'
          DefaultGateway  = '10.0.2.2'
          Hostname        = 'DC'

          # AD Configuration
          
          DomainDnsName     = 'trace.local'
          DomainNetBiosName = 'trace'

          PSDscAllowPlainTextPassword = $true

        }
    )
}
