<#
.NAME
	Install-IIS.ps1
.SYNOPSIS
	Uses PowerShell to customize a Windows base image for IIS
.AUTHOR
	Dan Tracey
.DATE
	25 / 01 / 2018
.VERSION
	1.0
.CHANGELOG
    25 / 01 / 2018 - v1.0 - Initial Script (DanT)
#>

# Variables
param(
[string]$hostname,
[string]$adminUser,
[securestring]$adminPassword,
[string]$vC,
[string]$vCUser,
[securestring]$vCPassword,
[string]$driveLetter = 'D',
[string]$driveCapacity = '20',
[string]$driveLabel = 'IIS Data'
)

$VerbosePreference = 'Continue'

Write-Verbose -Message "Installing IIS to Drive $Drive`:\"

Write-Verbose -Message 'Setting PowerShell Remoting Session Options...'
    $so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

Write-Verbose -Message 'Creating Credentials Object...'
    $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "localhost\$adminUser", $adminPassword
    $vCCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vcUser, $vCPassword

Write-Verbose -Message 'Adding PowerCLI Module...'
	$VerbosePreference = 'SilentlyContinue'
    Import-Module VMware.VimAutomation.Core -Verbose:$false
	$VerbosePreference = 'Continue'

Write-Verbose -Message 'Removing any existing PS Sessions using the $`session variable...'
	$session = $null

Write-Verbose -Message "Connecting to vCenter $vC as $vCUser..."
    $visession = Connect-VIServer $vC -Cred $vCCredentials -WarningAction 'SilentlyContinue'

Write-Verbose -Message "Retrieving VM Object for $hostName..."
    $vmObj = Get-VM $hostName

if (($vmObj | Get-HardDisk).Count -lt 2){

    Write-Verbose -Message "Powering down $hostName..."
    if ( $vmObj.PowerState -eq "PoweredOn" ) {
        Stop-VMGuest $vmObj -Confirm:$false
        do {
            # "Refresh" VM state every second.
			Write-Verbose -Message 'Sleeping for 5 Seconds'
            Start-Sleep -Seconds 5
            $vmObj = Get-VM $vmObj
            } until($vmObj.PowerState -eq 'PoweredOff')
        }

    Write-Verbose -Message 'Adding Additional Hard Disks...'
        New-HardDisk -VM $vmObj -CapacityGB $driveCapacity -DiskType Flat -StorageFormat Thin

    Start-Sleep 5

    Write-Verbose -Message "Powering on $hostName..."
    if ( $vmObj.PowerState -eq "PoweredOff" ) {
        Start-VM $vmObj -Confirm:$false
        do {
            # "Refresh" VM state every second.
			Write-Verbose -Message 'Sleeping for 5 Seconds'
            Start-Sleep -Seconds 5
            $vmObj = Get-VM $vmObj
            } until($vmObj.ExtensionData.Guest.ToolsRunningStatus -eq 'guestToolsRunning')
        }

    Disconnect-VIServer * -Confirm:$false

    Write-Verbose -Message "Connecting to $hostname via WinRM..."
        $session = $null
        $count = 0
        $complete = $false
        while (-not $session) {
            try {
                $session = New-PSSession -ComputerName $hostName -UseSSL -SessionOption $so -Credential $Credentials
                $complete = $true
                Write-Host "Connected to $hostname via WinRM"
            } catch {
                if ( $count -ge 5 ) {
                    Write-Error $_.Exception.Message
                    throw "Unable to connect to $hostname via WinRM!"
                } else {
                    $count++
                    Start-Sleep 10

                }
            }
        }

    Write-Verbose -Message 'Ensuring CD-ROM Drive Letter is Z:\ ...'
        Invoke-Command -Session $session -ScriptBlock {
            Set-Content C:\DiskPart.txt "select volume 0"
            Add-Content C:\DiskPart.txt "`nassign letter=z"
            Start-Process DiskPart.exe -ArgumentList "/s C:\DiskPart.txt"
            Remove-Item C:\DiskPart.txt
        }

    Write-Verbose -Message 'Configuring additional disks...'

        function Online-Disk {
            [CmdletBinding()]
            param(
                [string]$driveLabel,
                [string]$driveLetter,
                [string]$disk,
                [string]$file = 'C:\DiskPart.txt'
        )
            Invoke-Command -Session $session -ScriptBlock {
                Set-Content $using:file "select disk $using:disk"
                Add-Content $using:file "`nonline disk"
                Start-Process DiskPart.exe -ArgumentList "/s $using:file" -Wait -PassThru
                    Start-Sleep 5
                Remove-Item $using:file
                    Start-Sleep 5
            }
        }

        function Configure-Disk {
            [CmdletBinding()]
            param(
                [string]$driveLabel,
                [string]$driveLetter,
                [string]$disk,
                [string]$file = 'C:\DiskPart.txt'
        )
            Invoke-Command -Session $session -ScriptBlock {
                Set-Content $using:file "select disk $using:disk"
                Add-Content $using:file "`nattribute disk clear readonly"
                Add-Content $using:file "`ncreate partition primary align=1024"
                Add-Content $using:file "`nassign letter=$using:driveLetter"
                Add-Content $using:file "`nformat fs=ntfs unit=64K label=$using:driveLabel quick"
                Start-Process DiskPart.exe -ArgumentList "/s $using:file" -Wait -PassThru
                    Start-Sleep 5
                Remove-Item $using:file
                    Start-Sleep 5
            }
        }

        Online-Disk    $driveLabel $driveLetter 1
        Configure-Disk $driveLabel $driveLetter 1

}

if ( $visession.IsConnected ){ Disconnect-VIServer * -Confirm:$false }

if (!($session)){

    Write-Verbose -Message "Connecting to $hostname via WinRM..."
        $session = $null
        $count=0
        $complete = $false
        while (-not $session) {
            try {
                $session = New-PSSession -ComputerName $hostName -UseSSL -SessionOption $so -Credential $Credentials
                $complete = $true
                Write-Verbose -Message "Connected to $hostname via WinRM"
            } catch {
                if ( $count -ge 5 ) {
                    Write-Error $_.Exception.Message
                    throw "Unable to connect to $hostname via WinRM!"
                } else {
                    $count++
                    Start-Sleep 10

                }
            }
        }
}

Write-Verbose -Message 'Obtaining OS information...'
	$os = Invoke-Command -Session $session -ScriptBlock { (Get-WmiObject -class Win32_OperatingSystem).Caption }

Write-Verbose -Message "OS: $OS"

Write-Verbose -Message 'Installing IIS...'
if ($os.Trim() -match "Microsoft Windows Server 2008 R2"){
    $services = @("W3SVC","iisadmin")
    Invoke-Command -Session $session -ScriptBlock {

        Import-Module ServerManager ; Add-WindowsFeature -Name Web-Common-Http,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Http-Logging,Web-Request-Monitor,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Performance,Web-Mgmt-Console,Web-Mgmt-Compat,RSAT-Web-Server,WAS -IncludeAllSubFeature -Verbose

    }
}
elseif (($os.Trim() -match "Microsoft Windows Server 2012") -or ($os.Trim() -match "Microsoft Windows Server 2016")){
    $services = @("W3SVC")
    Invoke-Command -Session $session -ScriptBlock {

        Install-WindowsFeature Web-Server -IncludeManagementTools -Verbose

    }
}

Write-Verbose -Message 'Configuring IIS...'
    Invoke-Command -Session $session -ScriptBlock {
        Import-Module WebAdministration

        # Stopping Services
        $using:services | Stop-Service -Verbose
        xcopy $($env:SystemDrive+"\inetpub") $($using:driveLetter+":\inetpub") /O /E /I /Q /Y

        Set-Location "HKLM:\System\CurrentControlSet\Services\WAS\Parameters"
        Set-ItemProperty . -name ConfigIsolationPath $($using:driveLetter+":\inetpub\temp\appPools")

        # Ensure Service Pack and Hotfix Installers know where the IIS root directories are
        Set-Location "HKLM:\Software\Microsoft\inetstp"
        Set-ItemProperty . -name PathWWWRoot $($using:driveLetter+":\inetpub\wwwroot")
        Set-ItemProperty . -name PathWWWRoot $($using:driveLetter+":\inetpub\ftproot")
        Set-Location "HKLM:\Software\Wow6432Node\Microsoft\inetstp"
        Set-ItemProperty . -name PathWWWRoot $($using:driveLetter+":\inetpub\wwwroot")
        Set-ItemProperty . -name PathWWWRoot $($using:driveLetter+":\inetpub\ftproot")

        #Move logfile directories
        Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name traceFailedRequestsLogging.directory -value $($using:driveLetter+":\inetpub\logs\FailedReqLogFiles")
        Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory -value $($using:driveLetter+":\inetpub\logs\logfiles")
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter  "system.applicationHost/log" -name centralBinaryLogFile.directory  -value $($using:driveLetter+":\inetpub\logs\logfiles")
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter  "system.applicationHost/log" -name centralW3CLogFile.directory  -value $($using:driveLetter+":\inetpub\logs\logfiles")
        Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name ftpServer.logfile.directory -value $($using:driveLetter+":\inetpub\logs\LogFiles")
        Set-WebConfigurationProperty "/system.ftpServer/log" -name centralLogFile.directory -value $($using:driveLetter+":\inetpub\logs\LogFiles")

        # Move config history location, temporary files, the path for the Default Web Site and the custom error locations
        Set-WebConfigurationProperty "/system.applicationhost/configHistory" -name path -value $($using:driveLetter+":\inetpub\history")
        Set-WebConfigurationProperty "system.webServer/asp" -name cache.disktemplateCacheDirectory -value $($using:driveLetter+":\inetpub\temp\ASP Compiled Templates")
        Set-WebConfigurationProperty "system.webServer/httpCompression" -name directory -value $($using:driveLetter+":\inetpub\temp\IIS Temporary Compressed Files")
        Set-ItemProperty 'IIS:\Sites\Default Web Site\' -Name physicalPath -Value $($using:driveLetter+":\inetpub\wwwroot")
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='401']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='403']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='404']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='405']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='406']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='412']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='500']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='501']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}
        Set-WebConfiguration -Filter "/System.WebServer/HttpErrors/Error[@StatusCode='502']" -Value @{PrefixLanguageFilePath=$($using:driveLetter+":\inetpub\custerr")}

        # Start the Services
        $using:services | Start-Service -Verbose
    }

Write-Verbose -Message 'Creating scheduled task to manage IIS logs...'
    $scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Copy-Item -ToSession $session -Path $scriptPath\IISLogsCleanup.ps1 -Destination $($driveLetter+":\inetpub\") -Verbose

Invoke-Command -Session $session -ScriptBlock {

	$ErrorActionPreference = 'SilentlyContinue'

	if (!(Get-ScheduledTask IISLogsCleanup)){

		$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -Command ""& $using:driveLetter`:\inetpub\IISLogsCleanup.ps1"" -Logpath ""$using:driveLetter`:\inetpub\logs\logfiles\W3SVC1""" -WorkingDirectory D:\inetpub
		$trigger =  New-ScheduledTaskTrigger -Daily -At 1am

		Register-ScheduledTask -User $using:adminUser -Password $using:adminPassword -Action $action -Trigger $trigger -TaskName "IISLogsCleanup" `
		-Description "PowerShell script to compress and archive IIS Logs.  The script will check the specified folder and any files older than the first day of the previous month will be compressed into a zip file and optionally archived to another location."

	}
}
# Clean up
Write-Verbose -Message "Disconnecting WinRM session from $hostname..."
$session | Remove-PSSession

Write-Verbose -Message 'Install-IIS.ps1 - Script Complete'
#End
