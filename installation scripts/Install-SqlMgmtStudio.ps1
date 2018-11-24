<#
.NAME
	Install-SSMS.ps1
.SYNOPSIS
	Uses PowerShell to install the SQL Server Management Studio
.AUTHOR
	Dan Tracey
.DATE
	09 / 03 / 2018
.VERSION
	1.0
.CHANGELOG
    09 / 03 / 2018 - v1.0 - Initial Script (DanT)
#>

#Requires -Version 5
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=1)]
	[string]$hostname,
    [Parameter(Mandatory=$True, Position=2)]
	[string]$adminUser,
    [Parameter(Mandatory=$True, Position=3)]
	[securestring]$adminPassword,
    [Parameter(Mandatory=$True, Position=4)]
    [ValidateSet('2016','2017')]
	[string]$ssmsVersion
    )
# Variables
$url = <redacted>

$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'Continue'

Write-Verbose -Message "Sql Server Management Studio Version: $ssmsVersion"

Write-Verbose -Message 'Importing PSInfraHosting PowerShell Module...'
    Import-Module PSInfraHosting

Write-Verbose -Message "Connecting to $hostname via WinRM..."
    $psSession = Connect-PSRemoteSession $hostname $adminUser $adminPassword

Write-Verbose -Message 'Obtaining OS information...'
	$os = Invoke-Command -Session $psSession -ScriptBlock { (Get-WmiObject -class Win32_OperatingSystem).Caption }

Write-Verbose -Message "OS: $os"

Write-Verbose -Message "Beginning the Installation"
    Invoke-Command -Session $psSession -ScriptBlock {

    $VerbosePreference = 'Continue'
    
    Write-Verbose -Message 'Downloading SQL Server Management Studio...'
		(New-Object System.Net.WebClient).DownloadFile($url,"$env:TEMP\SSMS-Setup-ENU.exe")

    Write-Verbose -Message 'Installing SQL Server Management Studio...'
        try
        {
            Start-Process .\SSMS-Setup-ENU.exe -ArgumentList "/install /quiet /norestart /log ssms_install.txt" -WorkingDirectory $env:TEMP -Wait -PassThru
        }
        Catch 
        {
            Write-Error 'SQL Server Management Studio did not install successfully!'
        }
}

# Clean up
Write-Verbose -Message 'Cleaning up SQL Server Management Studio installation files...'
    Invoke-Command -Session $psSession -ScriptBlock {

        $VerbosePreference = 'Continue'
        $ErrorActionPreference = 'Stop'

        $retries = 5
        $retrycount = 0
        $secondsDelay = 2
        $completed = $false

        Set-Location $env:TEMP

        while (-not $completed) {
            try {
                if ( Test-Path $env:TEMP\SSMS-Setup-ENU.exe ) { Remove-Item $env:TEMP\SSMS-Setup-ENU.exe -Force }
                                $completed = $true
            } catch {
                if ($retrycount -ge $retries) {
                    Write-Verbose -Message "Command failed the maximum number of $retries times."
                    throw
                } else {
                    Write-Verbose -Message "Command failed - trying again in $secondsDelay seconds."
                    Start-Sleep $secondsDelay
                    $retrycount++
                }
            }
        }
}

Write-Verbose -Message "Disconnecting from $hostname..."
$psSession | Remove-PSSession
# End
