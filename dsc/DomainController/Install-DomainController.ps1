<#
    .NAME
        Install-DomainController.ps1
    .SYNOPSIS
        Uses PowerShell DSC to Install an Active Directory Domain Controller
    .AUTHOR
        Dan Tracey
    .DATE
        05 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        05 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

#Requires -Version 5
#Requires -Modules xActiveDirectory,ComputerManagementDsc,NetworkingDsc

# Variables
Param(

    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [SecureString]$AdminPassword

)

$VerbosePreference = 'Continue'

$DomainAdminUser = 'Administrator'
$DomainAdminPass = $AdminPassword
$SafeModePass= $AdminPassword


Write-Verbose -Message 'Creating Credentials Objects...'
# Domain Admin Creds
$DomainAdminSecPass = ConvertTo-SecureString -String $DomainAdminPass -AsPlainText -Force
$DomainAdminCreds = New-Object System.Management.Automation.PSCredential($DomainAdminUser,$DomainAdminSecPass)

# SafeMode Creds
$SafeModeSecPass = ConvertTo-SecureString -String $SafeModePass -AsPlainText -Force
$SafeModeCreds = New-Object System.Management.Automation.PSCredential("NoUserNeeded",$SafeModeSecPass)

Remove-DscConfigurationDocument -Stage Current -Force

Write-Verbose -Message 'Configuring AD Pre-Reqs...'
. .\AdPreReqs.ps1 

AdPreReqs -ConfigurationData .\ConfigurationData.psd1

Set-DscLocalConfigurationManager -Path .\AdPreReqs

Start-DscConfiguration -Path .\AdPreReqs -ComputerName localhost -Force -Wait -Verbose

Remove-DscConfigurationDocument -Stage Current -Force



Write-Verbose -Message 'Installing Domain Controller...'
. .\DomainController.ps1 

DomainController -ConfigurationData .\ConfigurationData.psd1 -DomainAdminCreds $DomainAdminCreds -SafeModeCreds $SafeModeCreds

Start-DscConfiguration -Path .\DomainController -ComputerName localhost -Force -Wait -Verbose 

Remove-DscConfigurationDocument -Stage Current -Force
