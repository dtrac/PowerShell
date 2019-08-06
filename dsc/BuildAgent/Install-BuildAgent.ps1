<#
    .NAME
        Install-BuildAgent.ps1
    .SYNOPSIS
        Uses PowerShell & DSC to Install an Azure DevOps Build Agent
    .AUTHOR
        Dan Tracey
    .DATE
        02 / 05 /2019
    .VERSION
        0.1
    .CHANGELOG
        02 / 05 /2019 - 0.1 - Initial Script (DanT)
#>

# Functions 
function ClearDscConfig {
    
    Remove-DscConfigurationDocument -Stage Pending -Force
    Remove-DscConfigurationDocument -Stage Current -Force
    
}

function DetermineScriptPath {

    try {
        $scriptPath = $PSScriptRoot
        if (!$scriptPath)
        {
            if ($psISE)
            {
                $scriptPath = Split-Path -Parent -Path $psISE.CurrentFile.FullPath
            } else {
                Write-Host -ForegroundColor Red "Cannot resolve script file's path"
                exit 1
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "Caught Exception: $($Error[0].Exception.Message)"
        exit 2
    }
    return $scriptPath
}
$scriptPath = DetermineScriptPath

# Vars
$VerbosePreference = 'Continue'

$data = Import-PowerShellDataFile $scriptPath\ConfigurationData.psd1

$nexus = '<ip>'

# Script
Write-Verbose -Message 'Configure MaxEnvelopeSizeKb...' # DT: seems to be required for chocolatey to install large packages...
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048

Write-Verbose -Message 'Installing Required DSC Modules...'
foreach ($Module in $data.Modules){
    
    $Module.Name

    foreach ($version in $Module.Versions) { 

        Write-Verbose -Message "Installing $($Module.Name) version $version..."

        $url = "http://$($nexus):8081/repository/windows-templating/dsc/$($Module.Name)/$version/$($Module.Name)-$version.zip"

        (New-Object System.Net.WebClient).DownloadFile($url, "C:\Windows\Temp\$($Module.Name).zip")
        Expand-Archive C:\Windows\Temp\$($Module.Name).zip 'C:\Program Files\WindowsPowerShell\Modules\' -Force
    

        Write-Verbose -Message "Cleaning up $($Module.Name)..."
        Remove-Item "C:\Windows\Temp\$($Module.Name).zip" -Confirm:$false -Force

        }
    }

Write-Verbose -Message 'Installing Chocolatey and Base Packages via DSC...'

. $scriptPath\BuildAgent.ps1 ; ClearDscConfig ; BuildAgent -OutputPath $scriptPath\BuildAgent

Start-DscConfiguration -Path $scriptPath\BuildAgent -ComputerName localhost -Force -Wait -Verbose ; ClearDscConfig


Write-Verbose -Message 'Installing Required Apps...'
foreach ($App in $data.Apps){
    
    

    foreach ($version in $App.Versions) { 

        Write-Verbose -Message "Installing $($App.Name) $version..." 
        if ($App.params) {
            C:\choco\choco.exe install $App.Name --version $version --params $App.params -my
        }
        else {
            C:\choco\choco.exe install $App.Name --version $version -my
        }
    }
}
