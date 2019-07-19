Configuration OctopusTentacle
{
    
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$octoCreds,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]$octoThumbprint,
       
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$domainCreds
        )
        

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xPSDesiredStateConfiguration
    Import-DscResource -Module OctopusDSC

    Node localhost
    {

        Package OctopusTentacleInstall
        {
            Ensure          = 'Present'
            Name            = 'Octopus Deploy Tentacle'
            Path            = "C:\Windows\Temp\Octopus.Tentacle.3.15.8-x64.msi"
            ProductId       = '7F1E2D6A-94DC-4500-8133-85E7726ECFBB'
        }

        Script ConfigureTentacle
        {
            SetScript = {

                $filePath = 'C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe'

                function Invoke-Process {
                    [CmdletBinding(SupportsShouldProcess)]
                    param
                    (
                        [Parameter(Mandatory)]
                        [ValidateNotNullOrEmpty()]
                        [string]$FilePath,

                        [Parameter()]
                        [ValidateNotNullOrEmpty()]
                        [string]$ArgumentList
                    )

                    $ErrorActionPreference = 'Stop'

                    try {
                        $stdOutTempFile = "$env:TEMP\$((New-Guid).Guid)"
                        $stdErrTempFile = "$env:TEMP\$((New-Guid).Guid)"

                        $startProcessParams = @{
                            FilePath               = $FilePath
                            ArgumentList           = $ArgumentList
                            RedirectStandardError  = $stdErrTempFile
                            RedirectStandardOutput = $stdOutTempFile
                            Wait                   = $true;
                            PassThru               = $true;
                            NoNewWindow            = $true;
                        }
                        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run with args: [$($ArgumentList)]")) {
                            $cmd = Start-Process @startProcessParams
                            $cmdOutput = Get-Content -Path $stdOutTempFile -Raw
                            $cmdError = Get-Content -Path $stdErrTempFile -Raw
                            if ($cmd.ExitCode -ne 0) {
                                if ($cmdError) {
                                    throw $cmdError.Trim()
                                }
                                if ($cmdOutput) {
                                    throw $cmdOutput.Trim()
                                }
                            } else {
                                if ([string]::IsNullOrEmpty($cmdOutput) -eq $false) {
                                    Write-Output -InputObject $cmdOutput
                                }
                            }
                        }
                    } catch {
                        $PSCmdlet.ThrowTerminatingError($_)
                    } finally {
                        Remove-Item -Path $stdOutTempFile, $stdErrTempFile -Force -ErrorAction Ignore
                    }
                }

                Start-Process netsh -ArgumentList "advfirewall firewall add rule `"name=Octopus Deploy Tentacle`" dir=in action=allow protocol=TCP localport=10933" -Wait -PassThru -NoNewWindow

                $install = @(
                    "create-instance --instance `"Tentacle`" --config `"C:\Octopus\Tentacle.config`" --console",
                    "new-certificate --instance `"Tentacle`" --if-blank --console",
                    "configure --instance `"Tentacle`" --reset-trust --console",
                    "configure --instance `"Tentacle`" --home `"C:\Octopus`" --app `"C:\Octopus\Applications`" --port `"10933`" --console",
                    "configure --instance `"Tentacle`" --trust $using:octoThumbprint",
                    "service --instance `"Tentacle`" --install --start --console"
                )

                foreach ($line in $install){
                    Invoke-Process -FilePath $filePath -ArgumentList $line
                }

            }
            TestScript = { 
                if( Get-WmiObject win32_service -Filter "name like 'OctopusDeploy Tentacle'"  )
                    {
                        return $true
                    }
                return $false
                }
            GetScript = { @{ 
                Result = (Get-WmiObject win32_product -Filter "name like 'Octopus Deploy Tentacle'") }
                }
            DependsOn       = "[Package]OctopusTentacleInstall"
        }
        
        xGroupSet AddUsersToLocalAdminsGroup
        {
            GroupName            = "Administrators"
            MembersToInclude     = $octoCreds.UserName
            Credential           = $domainCreds
        }

        xService OctoAccount
        {
            Name           = 'OctopusDeploy Tentacle'
            Credential     = $octoCreds
            StartupType    = 'Automatic'
            State          = 'Running'
            StartupTimeout = 30
            DependsOn      = "[Script]ConfigureTentacle"
        }

        xArchive OctoExtraction
        {
            Path        = "C:\Windows\Temp\octo.zip"
            Destination = 'C:\Program Files\Octopus Deploy\Tentacle\'
            Ensure      = 'Present'
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $false
        }
    }
}
