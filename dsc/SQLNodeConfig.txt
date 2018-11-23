@{
    AllNodes = @(
        @{
            NodeName                    = '%ComputerName%'
              
            BinaryStorePath             = '\\Path\to\Binaries\SQL2016_EntCoreMSDN-x64'
            SourcePath                  = "F:\updates"
            DSCSource                   = '\\Path\to\DSC\Modules'
            DSCPath                     = 'C:\Program Files\WindowsPowerShell\Modules'
            UpdateSource                = "F:\updates\Updates"
           
            PSDscAllowDomainUser        = $true
            PSDscAllowPlainTextPassword = $true
            UpdateEnabled               = "True"
            InstallSQLDataDir           = "D:\sql" 
            SQLUserDBDir                = "D:\sql\Data"
            SQLUserDBLogDir             = "E:\sql\Tranlog"
            SQLTempDBDir                = "G:\sql\Data"
            SQLTempDBLogDir             = "E:\sql\Tranlog"
            SQLBackupDir                = "F:\sql\Backup"
            
            BrowserSvcStartupType       = "Automatic"
            Features                    = "SQLENGINE,CONN"
            SQLSysAdminAccounts         = "DOMAIN\SQL Server Admins"
            AccountName                 = "SQL Server Admin"
            ProfileName                 = "SQL Server"
            EmailAddress                = "redacted"
            ReplyToAddress              = "redacted" 
            operator_email_address      = "redacted"
            MailServerName              = "redacted" 
            DisplayName                 = "SQL Server - %ComputerName%" 
            Description                 = "Mail Account" 
            LoggingLevel                = "Normal" 
            MailTcpPort                 = 25
            NetworkTcpPort              = 1433
            CostThresholdForParallelism = 50
            BackupCompressionDefault    = 1
            BackupChecksumDefault       = 1
            EnableDatabaseMailXPs       = 1
            SQLRemoteDAC                = 1
            PrincipalViewServerState    = 'redacted'
            TraceFlags                  = 'redacted'
         
        }
    )
}
