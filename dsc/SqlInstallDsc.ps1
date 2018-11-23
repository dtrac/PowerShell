<#
.NAME
	SqlInstallDsc.ps1
.SYNOPSIS
	Uses PowerShell DSC modules to install and configure SQL Server
.AUTHOR
	Dan Tracey
.DATE
	23 / 11 / 2018
.VERSION
	1.0
.CHANGELOG
	23 / 11 / 2018 - v1.0 - Initial Script (DanT
#>

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]

Configuration 'SqlInstall'
    {
        param
        (
            [Parameter()]
            [ValidateNotNullorEmpty()]
            [string]
            $ComputerName = 'localhost',
            
            [Parameter()]
            [ValidateNotNullorEmpty()]
            [string]
            $SQLInstanceName =  'MSSQLSERVER',
            
            [Parameter()]
            [ValidateNotNullorEmpty()]
            [string]
            $Collation  = "SQL_Latin1_General_CP1_CI_AS" ,
            
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [System.Management.Automation.PSCredential]
            $SqlInstallCredential,
            
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [System.Management.Automation.PSCredential]
            $SqlServiceCredential,
            
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [System.Management.Automation.PSCredential]
            $SqlAgentServiceCredential

        )

        if ($SQLInstanceName -eq 'MSSQLSERVER')
           {
              $SQLServerInstance = $ComputerName
           }
		    else
           {
              $SQLServerInstance = $ComputerName + '\' +  $SQLInstanceName
           }

	  Import-DscResource –Module 'PSDesiredStateConfiguration'
    Import-DscResource -Module 'SqlServerDsc'
	  Import-DscResource -Module 'SecurityPolicyDsc'

	Node $ComputerName
        {

            File CopySQLFiles
            {
            	Ensure = "Present"
            	Type = "Directory"
            	Recurse = $true
            	MatchSource = $true
            	SourcePath = $Node.BinaryStorePath
            	DestinationPath = $Node.SourcePath
            }

      	    WindowsFeature 'NetFramework45'
            {
            	Name   = 'NET-Framework-45-Core'
            	Ensure = 'Present'
            }

      	    WindowsFeature TelnetClient
            {
            	Ensure = 'Present'
            	Name = 'Telnet-Client'
            }

      	    WindowsFeature ADDS
            {
            	Ensure = 'Present'
            	Name = 'RSAT-ADDS-Tools'
			      }

            WindowsFeature ADPS
            {
            	Ensure = 'Present'
            	Name = 'RSAT-AD-PowerShell'
            }

      	    UserRightsAssignment PerformVolumeMaintenanceTasks
            {
            	Policy = "Perform_volume_maintenance_tasks"
                Identity = $SqlServiceCredential.UserName
            }

      	    SqlSetup 'InstallSQL'
            {
            	DependsOn = '[File]CopySQLFiles'
                Features = $Node.Features
                InstanceName = $SQLInstanceName
                SQLCollation =  $Collation
                SQLSysAdminAccounts =  $Node.SQLSysAdminAccounts
                InstallSQLDataDir = $Node.InstallSQLDataDir
                SQLUserDBDir = $Node.SQLUserDBDir
                SQLUserDBLogDir = $Node.SQLUserDBLogDir
                SQLTempDBDir = $Node.SQLTempDBDir
                SQLTempDBLogDir = $Node.SQLTempDBLogDir
                SQLBackupDir = $Node.SQLBackupDir
                UpdateEnabled = $Node.UpdateEnabled
                UpdateSource = $Node.UpdateSource
                SQLSvcAccount = $SqlServiceCredential
                AgtSvcAccount = $SqlAgentServiceCredential
         		    BrowserSvcStartupType = $Node.BrowserSvcStartupType
                SourcePath = $Node.SourcePath
                PsDscRunAsCredential = $SqlInstallCredential
                SuppressReboot = $true
            }

            Registry SqlServiceDependencies
            {
                Ensure      = "Present"
                Key         = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\MSSQL`$$SQLInstanceName"
                ValueName   = "DependOnService"
                ValueData   = @("KeyIso","W32Time","Netlogon")
                ValueType   = "MultiString"
                DependsOn   = '[SqlSetup]InstallSQL'
            }
            
            # If the machine needs a reboot, the DSC resource sets it to reboot.
            If ($Result.rebootRequired) {
                $global:DSCMachineStatus = 1
            }
        }
    }
      	    SqlServerNetwork ChangeTcpIpOnDefaultInstance
            {
                ServerName           = $ComputerName
                InstanceName         = $SQLInstanceName
                ProtocolName         = 'Tcp'
                IsEnabled            = $true
                TCPDynamicPort       = $false
                TCPPort              = $Node.NetworkTcpPort
                DependsOn            = '[SqlSetup]InstallSQL'
                PsDscRunAsCredential = $SqlInstallCredential
            }
        }
    }
