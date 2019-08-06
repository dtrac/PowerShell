@{
    AllNodes = @(
        @{

          NodeName = 'localhost'

          # OS Configuration

          Hostname = 'DEV-DT-HOST'
          DNSServer = '10.1.1.1'
         
          # AD Configuration
          
          DomainDnsName     = 'domain.local'

          PSDscAllowPlainTextPassword = $true
          PSDscAllowDomainUser = $true

        }
    )
}
