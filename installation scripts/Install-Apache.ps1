<#
.SYNOPSIS
    Basic apache installation via PowerShell 
.DESCRIPTION
    Installs, starts, configures and tests apache webserver via PowerShell
.EXAMPLE
    Install-Apache -url https://path.to.repo -apacheInstallPath C:\ProgramFiles\apache24
.AUTHOR
    Dan Tracey
.VERSION
    1.0
.CHANGELOG
    01 / 07 / 2016 - v1.0 - Initial Script - tested with apache 2.4 (DanT)
#>
function Install-Apache {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$apacheInstallPath
        )

$VerbosePreference = "Continue"

Write-Verbose -Message 'Checking for previous versions of apache and stopping if required...'
    if (Get-Service Apache*){Stop-Service Apache*}

Write-Verbose -Message 'Checking for W3SVC and stopping if required...'
    if (Get-Service W3SVC){
        Stop-Service W3SVC
        Set-Service W3SVC -StartupType Disabled
    }

Write-Verbose -Message 'Downloading apache...'
	Invoke-Webrequest -uri $url -Outfile "$env:TEMP\apache.zip"

Write-Verbose -Message 'Unzipping apache...'
	if (!(Test-Path $apacheInstallPath)){ New-Item -Type Directory $apacheInstallPath}
	$VerbosePreference = "SilentlyContinue"
	Expand-Archive -Path "$env:TEMP\apache.zip" -DestinationPath $apacheInstallPath -Force
	$VerbosePreference = "Continue"

Write-Verbose -Message 'Installing apache...'
	Start-Process -WorkingDirectory "$apacheInstallPath\Apache24\bin" -FilePath .\httpd.exe -ArgumentList '-k install' -Wait

Write-Verbose -Message 'Configuring apache...'
	( Get-Content -Path $apacheInstallPath\Apache24\conf\httpd.conf) |
		ForEach-Object { $_ -replace 'c:/Apache24' , "$apacheInstallPath/Apache24" } |
		Set-Content -Path $apacheInstallPath\Apache24\conf\httpd.conf

Write-Verbose -Message 'Starting apache...'
	Start-Service -Name Apache*

Write-Verbose -Message 'Testing apache...'
	$url = 'http://localhost' ;
	$req = [net.webrequest]::Create($url) ;
	$response = $req.GetResponse() ;
	$exitCode = $response.StatusCode.ToString()

	if ($exitCode.Trim() -ne 'OK' )
	{
		throw "Apache web page is not responding - Exit code $response.StatusCode.value__"
    }
}
