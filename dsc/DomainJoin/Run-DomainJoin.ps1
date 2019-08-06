<#
    .NAME
        Run-DomainJoin.ps1
    .SYNOPSIS
        Uses PowerShell DSC to join an AD domain
    .AUTHOR
        Dan Tracey
    .DATE
        08 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        08 / 04 /2019 - 0.1 - Initial Script (DanT)
#>


#Requires -Version 5
#Requires -Modules ComputerManagementDsc,NetworkingDsc
Param(

    [Parameter(Mandatory=$true, HelpMessage="Enter credentials of an account with permission to join the domain (domain\username)")]
    [ValidateNotNullorEmpty()]
    [PSCredential]$DomainJoinCreds

)

function ClearDscConfig {
    
    Remove-DscConfigurationDocument -Stage Pending -Force
}
ClearDscConfig

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

$VerbosePreference = 'Continue'

Write-Verbose -Message 'Joining Domain...'

. $scriptPath\DomainJoinConfiguration.ps1 ; DomainJoin -ConfigurationData $scriptPath\ConfigurationData.psd1 -DomainJoinCreds $DomainJoinCreds -OutputPath $scriptPath\DomainJoin

Set-DscLocalConfigurationManager -Path $scriptPath\DomainJoin

Start-DscConfiguration -Path $scriptPath\DomainJoin -ComputerName localhost -Force -Wait -Verbose

ClearDscConfig
