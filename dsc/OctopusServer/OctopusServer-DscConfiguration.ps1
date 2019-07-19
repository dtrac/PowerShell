Configuration OctopusServer
{
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$OctoAdminCreds,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$OctoSvcCreds,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$SACreds
    )

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module NetworkingDsc
    Import-DSCResource -Module xSystemSecurity
    Import-DscResource -Module SqlServerDsc
    Import-DscResource -Module OctopusDSC

    Node localhost
    {
        
        Registry 'DoNotOpenServerManagerAtLogon'
        {
            Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager"
            ValueName   = "DoNotOpenServerManagerAtLogon"
            ValueData   = "1"
            ValueType   = 'Dword'
        }

        FirewallProfile 'ConfigurePrivateFirewallProfile'
        {
            Name        = 'Private'
            Enabled     = 'False'
        }

        FirewallProfile 'ConfigurePublicFirewallProfile'
        {
            Name        = 'Public'
            Enabled     = 'False'
        }

        FirewallProfile 'ConfigureDomainFirewallProfile'
        {
            Name        = 'Domain'
            Enabled     = 'False'
        }

        xIEEsc 'DisableIEEscAdmin'
        {
            IsEnabled   = $false
            UserRole    = "Administrators"
        }

        xIEEsc 'DisableIEEscUser'
        {
            IsEnabled   = $false
            UserRole    = "Users"
        }

        Package 'InstallChrome'
        {
            Name            = "Google Chrome"
            Path            = 'C:\Windows\Temp\GoogleChromeStandaloneEnterprise64.msi'
            ProductId       = "7846BE0D-4594-30DC-9822-FE08C0042106"
        }

        WindowsFeatureSet 'dotnetfx'
        {
            Name        = "NET-Framework-Core"
            Ensure      = "Present"
            Source      = "C:\Windows\Temp"
        }

        
        WindowsFeature 'NetFramework45'
        {
            Name        = 'NET-Framework-45-Core'
            Ensure      = 'Present'
        }

        Package 'VCRedistInstallx64'
        {
            Ensure      = 'Present'
            Name        = "Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026"
            Path        = "C:\Windows\Temp\vcredist.exe"
            ProductId   = "A1C31BA5-5438-3A07-9EEE-A5FB2D0FDE36"
	          Arguments   = "/s /L `"C:\Install\Logs\VCRedist2015x64_InstallLog.txt`""
            ReturnCode  = @(0,1638)
        }

        Archive 'ExtractSQLBinaries'
        {
            Ensure      = "Present" 
            Path        = "C:\Windows\Temp\sqlserver-express.zip"
            Destination = 'C:\SQLEXPRESS2017'
        }
        
        User 'CreateOctoSvcAcc'
        {
            Ensure   = "Present"
            UserName = "OctoSvc"
            Password = $OctoSvcCreds
        }

        GroupSet 'AddOctoSvcToAdminGroups'
        {
            GroupName        = @("Administrators")
            Ensure           = "Present"
            MembersToInclude = @("OctoSvc")
        }
        
        SqlSetup 'InstallDefaultInstance'
        {
            InstanceName         = 'MSSQLSERVER'
            Features             = 'SQLENGINE'
            SourcePath           = 'C:\SQLEXPRESS2017'
            SQLSysAdminAccounts  = @('Administrators','OctoSvc')
            SecurityMode         = 'SQL'
            SAPwd                = $SACreds
            PsDscRunAsCredential = $OctoSvcCreds
            DependsOn            = '[WindowsFeature]NetFramework45','[Archive]ExtractSQLBinaries'
        }
        
        SqlDatabase 'CreateOctopusDatabase'
        {
            Ensure       = 'Present'
            ServerName   = 'localhost'
            InstanceName = 'MSSQLSERVER'
            Name         = 'Octopus'
            PsDscRunAsCredential = $OctoSvcCreds

        }
        
        SqlServerNetwork 'EnableSqlProtocols'
        {
            InstanceName    = 'MSSQLSERVER'
            ProtocolName    = 'tcp'
            IsEnabled       = $true
        }

        Package 'InstallSSMS'
        {
            Name        = "Microsoft SQL Server Management Studio - 17.2"
            Path        = 'C:\Windows\Temp\SSMS-Setup-ENU.exe'
            ProductId   = "CD1FA99A-EEF9-44BE-8A89-8FB17F1C5437"
            Arguments   = "/install /quiet /norestart /log C:\Install\Logs\ssms_install.log"
        }

        cOctopusServer 'OctopusServer'
        {
            Ensure      = "Present"
            State       = "Started"

            # Server instance name. Leave it as 'OctopusServer' unless you have more than one instance
            Name        = "OctopusServer"

            # The url that Octopus will listen on
            WebListenPrefix = "http://localhost:80"
            SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;"
           
            # The admin user to create
            OctopusAdminCredential   = $OctoAdminCreds

            # optional parameters
            DownloadUrl                      = "https://octopus.com/downloads/latest/WindowsX64/OctopusServer"
            AllowUpgradeCheck                = $false
            AllowCollectionOfUsageStatistics = $false
            ForceSSL                         = $false
            ListenPort                       = 10943
            #LegacyWebAuthenticationMode      = "UsernamePassword"

            PsDscRunAsCredential = $OctoSvcCreds
        }      
    }
}
