#region variables
$VMs = @('host1','host2','host3')
$vCenter = 'vCenter.local'
$creds = Get-Credential -Message 'Enter vCenter username and password' -UserName domain\username
#endregion variables

#region Connect to vCenter
Connect-VIServer $vCenter -Cred $creds
#endregion Connect to vCenter

#region - Return info for Deployment Targets
$guestCreds = Get-Credential -UserName 'dlr\traceyd' -Message 'Enter Guest Creds'
[System.Collections.ArrayList]$arr = @()
$Props = $null
$VM = $null
foreach ($VM in $VMs){
     
     "Working on $VM..."
     $Props = [pscustomobject]@{
     
        name = (Get-VM -Name $VM -Verbose:$false).Name
        ip = Get-VM -Name $VM -Verbose:$false | Select @{N="IP";E={@($_.Guest.IPAddress | Where {$_ -notlike "*fe80*"})}} | foreach {$_.IP}
        thumbprint = Invoke-Command -Credential $guestCreds -ComputerName $VM -ScriptBlock {
            $VerbosePreference = 'Continue'
            Try{
                $response = & 'C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe' show-configuration | ConvertFrom-Json
                Write-Output $($response.Tentacle.CertificateThumbprint)
            }
            Catch [System.Management.Automation.CommandNotFoundException]{
                Write-Warning 'Tentacle.exe not found - check it''s installed!'
            }
         }
     }
    $arr.add($props) | Out-Null
}
$arr | ft -Wrap
#endregion - Return info for Deployment Targets
