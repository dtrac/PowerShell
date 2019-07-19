<#
#region functions
Functions removed for brevity :
- Get-NexusArtifact
- ClearDcsConfig
- CreateCreds
- DetermineScriptPath
#endregion functions
#>

#region variables
$VerbosePreference = 'Continue'

$manifest = Import-PowerShellDataFile $scriptPath\Manifest.psd1
$OctoAdminCreds = CreateCreds -user octopus -password ''
$OctoSvcCreds = CreateCreds -user OctoSvc -password ''
$SACreds = CreateCreds -password ''
#endregion variables

#region Get Pre-Reqs
# Download Modules
foreach ($Module in $manifest.Modules){
    
   Write-Verbose -Message "Downloading $($Module.Name) version $($Module.version)..."

   Get-NexusArtifact -Component $Module.Name -Version $Module.version -Group $Module.Group -Type $Module.Type

   Expand-Archive "C:\Windows\Temp\$($Module.Name).$($module.Type)" 'C:\Program Files\WindowsPowerShell\Modules' -Force

}

# Download Binaries
foreach ($Binary in $manifest.Binaries){
    
    Write-Verbose -Message "Downloading $($Binary.Name) version $($Binary.version)..."

    Get-NexusArtifact -Component $Binary.Name -Version $Binary.version -Group $Binary.Group -Type $Binary.Type -TargetDir $Binary.TargetDir -TargetName $Binary.TargetName

}
#endregion Get Pre-Reqs

#region DSC
$cd = @{
    AllNodes = @(
        @{

          NodeName                    = 'localhost'
          PSDscAllowPlainTextPassword = $true
          PSDscAllowDomainUser        = $true

        }
    )
}

ClearDscConfig

# Install Octopus Server
. $scriptPath\OctopusServer-Configuration.ps1 ; OctopusServer -OutputPath $scriptPath\OctopusServer -OctoAdminCreds $OctoAdminCreds -OctoSvcCreds $OctoSvcCreds -SACreds $SACreds -ConfigurationData $cd
Start-DscConfiguration -Path $scriptPath\OctopusServer -ComputerName localhost -Force -Wait -Verbose ; ClearDscConfig

#endregion DSC

#region Configuration

# Octopus Config
# Enable Username and Password login
Start-Process 'Octopus.Server.exe' -WorkingDirectory 'C:\Program Files\Octopus Deploy\Octopus' -ArgumentList 'configure --usernamePasswordIsEnabled=true' -Wait -Verbose

#endregion Configuration
