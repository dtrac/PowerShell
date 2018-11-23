<#
.NAME
	Get-SCCMDevice.ps1
.SYNOPSIS
	Takes parameter input (e.g. from vRO), adds SCCM PowerShell Modules and checks existence of a computer object in SCCM.
.AUTHOR
	Dan Tracey
.DATE
	02 / 08 / 2016
.VERSION
	1.0
.CHANGELOG
	02 / 08 / 2016 - v1.0 - Initial Script (DanT)
#>

param(
[string]$computerName,
[string]$username,
[securestring]$password
)

# Create PS Credential
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$password
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Check whether device exists in SCCM
Invoke-Command -Authentication CredSSP -Credential $cred -ComputerName "$env:COMPUTERNAME.$env:USERDNSDOMAIN" -UseSSL -Port 5986 -SessionOption $so{

	Write-Host "Checking whether $using:computerName exists in SCCM..."

	Import-Module -Name "$(Split-Path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1" ;

	Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" ;

	# Check for SCCM device existence every 5 seconds for 1 minute to account for SCCM back-end latency
	$timeout = New-Timespan -Minutes 5
	$sw = [diagnostics.stopwatch]::StartNew()

	while ( $sw.elapsed -lt $timeout ) {
		if (Get-CMDevice -Name $using:computerName) {
			Write-Host "$using:computerName found in SCCM!"
			$success = $true
			return
		}
	Start-Sleep -Seconds 5
	}

	if (!($success)) {

		throw "$using:computerName not found in SCCM!"
	}

}
