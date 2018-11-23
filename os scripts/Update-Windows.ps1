<#
.NAME
	Update-Windows.ps1
.SYNOPSIS
	 Installs the PSWindowsUpdate PowerShell module, configures WSUS client settings and performs a Windows update
.AUTHOR
	Dan Tracey
.DATE
	25 / 09 / 2017
.VERSION
	1.0
.CHANGELOG
	25 / 09 / 2017 - v1.0 - Initial Script (DanT)
#>

# Variables
param(
[string]$hostName,
[string]$wsusServer,
[string]$guestUser,
[securestring]$guestPass
)
$webDeployURL = <REDACTED>

$VerbosePreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# PowerShell Remoting Configuration
Write-Verbose -Message 'Setting PowerShell Remoting Session Options...'
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

Write-Verbose -Message 'Creating Credentials Object...'
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "$hostName\$guestUser", $guestPass

Write-Verbose -Message "Connecting to $hostname..."
$session = New-PSSession -ComputerName $hostName -UseSSL -SessionOption $so -Credential $Credentials

Write-Verbose -Message 'Checking if WSUS Client is already configured...'
$regPath = "HKLM:\software\policies\Microsoft\Windows\WindowsUpdate"
$script = {(Get-ItemProperty -Path $using:regPath -Name WUServer).WUServer -eq $using:wsusserver}
$cmd = Invoke-Command -Session $session -ScriptBlock $script
	
	if ($cmd -eq $false){
		Write-Verbose -Message 'Configuring WSUS Client...'
		
		$script = {Test-Connection -Quiet $using:wsusserver -Count 1}
		$cmd = Invoke-Command -Session $session -ScriptBlock $script

		if ($cmd -eq $true) {

			$wsusServer="http://" + $wsusServer + ":8530"
			Write-Verbose -Message "Using WSUS: $wsusserver"
			
			$script = {
			
			stop-service wuauserv
			New-Item -Path "$using:regPath\AU" -force
			Set-ItemProperty -Path $using:regPath -Name WUServer -Value $using:wsusserver -Type String -force
			Set-ItemProperty -Path $using:regPath -Name WUStatusServer -Value $using:wsusserver -Type String -force
			Set-ItemProperty -Path "$using:regPath\AU" -Name UseWUServer -Value 1 -Type DWORD -force
			start-service wuauserv
			
			}
			
			$cmd = Invoke-Command -Session $session -ScriptBlock $script
		
		} else {
		
			Write-Verbose -Message 'Unable to contact the WSUS server.'
			exit 1
		
		}
	
	}
	
Write-Verbose -Message 'Checking if PSWindowsUpdateModule is already installed...'
$modulePath = 'C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate'
$script = {Test-Path $using:modulePath}
$cmd = Invoke-Command -Session $session -ScriptBlock $script
	
	if ($cmd -eq $false){
		Write-Verbose -Message 'Installing PSWindowsUpdate Module...'
		
		$script = {
		
			$filePath = "C:\Windows\Temp\PSWindowsUpdate.zip"

			(New-Object System.Net.WebClient).DownloadFile($webDeployURL, $filePath)

			$shell = New-Object -ComObject Shell.Application
			$zipFile = $shell.NameSpace($filePath)
			$destinationFolder = $shell.NameSpace("C:\Program Files\WindowsPowerShell\Modules")

			$copyFlags = 0x00
			$copyFlags += 0x04 # Hide progress dialogs
			$copyFlags += 0x10 # Overwrite existing files

			$destinationFolder.CopyHere($zipFile.Items(), $copyFlags)
		
			Remove-Item -Force -Path $filePath
		
		}
		
		$cmd = Invoke-Command -Session $session -ScriptBlock $script
		
	}

Write-Verbose -Message 'Running Windows Update...'
$script = {
		
	Try 
	{
		Import-Module PSWindowsUpdate -ErrorAction Stop
	}
	Catch
	{
		Write-Error "Unable to install PSWindowsUpdate"
		exit 1
	}

	try {
		$updateCommand = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\Windows\Temp\PSWindowsUpdate-VRO.log}
		$TaskName = "PackerUpdate"

		$User = [Security.Principal.WindowsIdentity]::GetCurrent()
		$Scheduler = New-Object -ComObject Schedule.Service

		$Task = $Scheduler.NewTask(0)

		$RegistrationInfo = $Task.RegistrationInfo
		$RegistrationInfo.Description = $TaskName
		$RegistrationInfo.Author = $User.Name

		$Settings = $Task.Settings
		$Settings.Enabled = $True
		$Settings.StartWhenAvailable = $True
		$Settings.Hidden = $False

		$Action = $Task.Actions.Create(0)
		$Action.Path = "powershell"
		$Action.Arguments = "-Command $updateCommand"

		$Task.Principal.RunLevel = 1

		$Scheduler.Connect()
		$RootFolder = $Scheduler.GetFolder("\")
		$RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, "SYSTEM", $Null, 1) | Out-Null
		$RootFolder.GetTask($TaskName).Run(0) | Out-Null

		Write-Output "The Windows Update log will be displayed below this message. No additional output indicates no updates were needed."
		do {
			sleep 1
			if ((Test-Path C:\Windows\Temp\PSWindowsUpdate-VRO.log) -and $script:reader -eq $null) {
				Write-Output 'Creating PSWindowsUpdate Log File...'
				$script:stream = New-Object System.IO.FileStream -ArgumentList "C:\Windows\Temp\PSWindowsUpdate-VRO.log", "Open", "Read", "ReadWrite"
				$script:reader = New-Object System.IO.StreamReader $stream
			}
			if ($script:reader -ne $null) {
				$line = $Null
				do {$script:reader.ReadLine()
					$line = $script:reader.ReadLine()
					Write-Output $line
				} while ($line -ne $null)
			}
		} while ($Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName})
	} finally {
		$RootFolder.DeleteTask($TaskName,0)
		[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Scheduler) | Out-Null
		if ($script:reader -ne $null) {
			$script:reader.Close()
			$script:stream.Dispose()
		}
	}
}

$cmd = Invoke-Command -Session $session -ScriptBlock $script

Write-Verbose -Message "Disconnecting from $hostname..."
$session | Remove-PSSession
# End
