$jsonFile = .\VMs.json
$vCenter = Read-Host 'vCenter FQDN'
$creds = Get-Credential -Message 'Enter vCenter username and password' 

# Connect to vCenter
Connect-VIServer $vCenter -Cred $creds

$vmsToCreate = Get-Content $jsonFile | ConvertFrom-Json

foreach ($VM in $vmsToCreate.vms){

    Write-Host "Working on $($VM.vmName)..." -ForegroundColor Yellow

    New-VM -Name $VM.vmName -Template $VM.vSphereTemplate -Datastore $VM.datastore -VMHost (Get-Cluster $VM.vSphereCluster | Get-VMHost | Get-Random) -Notes $VM.role -Confirm:$false -ResourcePool $VM.resourcePool -Location (Get-Folder $VM.folder)

    $vmObj = Get-VM $VM.vmName

    Set-VM -VM $vmObj -MemoryGB $VM.memoryGb -NumCpu $VM.vCPU -Confirm:$false

    $vmObj | Get-NetworkAdapter | Set-NetworkAdapter -PortGroup $VM.portgroup -Confirm:$false

    
    foreach ($additionalDisk in $VM.additionalDisks){

        Try {
            New-HardDisk -VM $vmObj -Persistence Persistent -DiskType Flat -CapacityGB $additionalDisk.driveSizeGb -StorageFormat Thin -WhatIf
        }
        Catch [System.Management.Automation.ParameterBindingException]{
            Write-Warning "No additional Disks required for $($VM.vmName)"
        }
    }

    Start-VM $vmObj | Wait-Tools
}

Disconnect-VIServer * -Confirm:$false
