#region parameters
Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]$octoUser,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [securestring]$octoPass,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]$domainUser,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [securestring]$domainPass,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]$octoThumbprint
        
        )
#endregion parameters

#region functions
<#
#region functions
Functions removed for brevity :
- Get-NexusArtifact
- ClearDcsConfig
- DetermineScriptPath
#endregion functions
#>
#endregion functions

#region variables
$VerbosePreference = 'Continue'
$scriptPath = DetermineScriptPath
$manifest = Import-PowerShellDataFile $scriptPath\manifest.psd1
#endregion variables

#region credentials
$octoCreds = New-Object System.Management.Automation.PSCredential($octoUser,$octoPass)
$domainCreds = New-Object System.Management.Automation.PSCredential($domainUser,$domainPass)
#endregion credentials

#region pre-reqs
foreach ($Module in $manifest.Modules){
    
   Write-Verbose -Message "Downloading $($Module.Name) version $($Module.version)..."

   Get-NexusArtifact -Component $Module.Name -Version $Module.version -Group $Module.Group -Type $Module.Type

   Expand-Archive "C:\Windows\Temp\$($Module.Name).$($module.Type)" 'C:\Program Files\WindowsPowerShell\Modules' -Force

}

foreach ($Binary in $manifest.Binaries){
    
    Write-Verbose -Message "Downloading $($Binary.Name) version $($Binary.version)..."

    Get-NexusArtifact -Component $Binary.Name -Version $Binary.version -Group $Binary.Group -Type $Binary.Type -TargetDir $Binary.TargetDir -TargetName $Binary.TargetName

}
#endregion pre-reqs

#region dsc
$cd = @{
    AllNodes = @(
        @{

          NodeName                    = 'localhost'
          PSDscAllowPlainTextPassword = $true
          PSDscAllowDomainUser        = $true

        }
    )
}

    # Clear any existing DSC config
    ClearDscConfig

    # Dot source the configuration
    . $scriptPath\OctopusTentacle-Configuration.ps1 

    # Compile the MOF file
    OctopusTentacle -OutputPath $scriptPath\OctopusTentacle -octoThumbprint $OctoThumbprint -octoCreds $OctoCreds -domainCreds $domainCreds -ConfigurationData $cd

    # Run the configuration on the target server
    Set-DscLocalConfigurationManager -Path $scriptPath\OctopusTentacle
    Start-DscConfiguration -Path $scriptPath\OctopusTentacle -Wait -Force -Verbose

    # Clear DSC config
    ClearDscConfig

#endregion dsc
