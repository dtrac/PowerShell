# DT - 30/04/2018
# Create vSphere tag Category 'Licensing' with multiple cardinality, and the 
# licensing tags to be used for separation, e.g 'oracle', 'linux', 'windows', 'sql' etc. (see $licCats array below).

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$vcUser,
    [Parameter(Mandatory=$true)]
    [string]$vcPassword
)

function Get-HostTags {
 param($vmhosts, $tag)
            
$taggedHosts = @()
foreach($vmhost in $vmhosts){
    $hostTagAssigned = $vmhost | Get-TagAssignment -Category "Licensing" -Verbose:$false
    if($hostTagAssigned){
        foreach($hosttagA in $hostTagAssigned){
        if($hosttagA.Tag.Name -eq $tag){
            $taggedHosts += $vmhost
            }
        }
    }
}
return $taggedHosts
}

function New-HostGroup {
 param($taggedHosts, [string]$groupName)

$hostGroup = Get-DrsClusterGroup -Cluster $cluster -Type VMHostGroup -Name $groupName -ErrorAction SilentlyContinue -Verbose:$false
    
if (!($hostGroup)){

    $hostGroup = New-DrsClusterGroup -Name $groupName -Cluster $cluster -VMHost $taggedHosts
               
    }

    foreach ($taggedHost in $taggedHosts){

        if ($hostGroup.Member -notcontains $taggedHost){

            Write-Verbose -Message "Adding $($taggedHost.Name) to $($hostGroup.Name)"
            Set-DrsClusterGroup -DrsClusterGroup $hostGroup -VMHost $taggedHost -Add

        }
    }
}

function New-VMGroup {
 param($vms, $groupName)

$vmGroup = Get-DrsClusterGroup -Cluster $cluster -Type VMGroup -Name $groupName -ErrorAction SilentlyContinue -Verbose:$false
    
if (!($vmGroup)){

    $vmGroup = New-DrsClusterGroup -Name $groupName -Cluster $cluster -VM $vms
               
    }

    foreach ($vm in $vms){

        if ($vmGroup.Member -notcontains $vm){

            Write-Verbose -Message "Adding $($vm.Name) to $($vmGroup.Name)"
            Set-DrsClusterGroup -DrsClusterGroup $vmGroup -VM $vm -Add

        }
    }
}

$licCats = @([pscustomobject]@{name='Windows Servers';tag='windows';hostGroup='WindowsHosts';vmGroup='WindowsVMs'},
             [pscustomobject]@{name='Linux Servers';tag='linux';hostGroup='LinuxHosts';vmGroup='LinuxVMs'},
             [pscustomobject]@{name='SQL Servers';tag='sql';hostGroup='SQLHosts';vmGroup='SQLVMs'}
             [pscustomobject]@{name='Oracle Servers';tag='oracle';hostGroup='OracleHosts';vmGroup='OracleVMs'})

if (!(Get-Module -Name VMware.VimAutomation.Core) -and (Get-Module -ListAvailable -Name VMware.VimAutomation.Core)) {
    Write-Host "Loading the VMware PowerCLI Modules..."
    Import-Module -Name VMware.VimAutomation.Core 
    Start-Sleep 5
    if (!(Get-Module -Name VMware.VimAutomation.Core)) {
        # Error out if loading fails
        Write-Error "Cannot load the VMware PowerCLI Module. Is PowerCLI installed?"
     }
    Write-Host "Loaded the VMware PowerCLI Modules..."
}

$VerbosePreference = 'Continue'

Write-Verbose -Message 'Specifing vCenter Instances...'
$vCenters = @(  
                'ukwkmh-vmua951.wtr.net',
                'ukjhmh-vmua951.wtr.net'
             )
Write-Verbose -Message "vCenters: $vCenters"


foreach ($vCenter in $vCenters){
    
    Write-Verbose -Message "Connecting to $vCenter"
    Connect-VIServer $vCenter -User $vcUser -Password $vcPassword

    Write-Verbose -Message 'Specifing Clusters...'
    $clusters = Get-Cluster -Verbose:$false | Where-Object { ($_.Name -like "*VMCD*") -or ($_.Name -like "*VMCM*") -or ($_.Name -like "*VMCS*")}

    Write-Verbose -Message "Clusters: $clusters"

    foreach ($cluster in $clusters) {

        Write-Verbose -Message "Working on $cluster..."

        $vmhosts = Get-Cluster $cluster -Verbose:$false | Get-VMHost -Verbose:$false

        foreach ($hostTag in $licCats){
              
            $taggedHosts = Get-HostTags $vmhosts $hostTag.tag

            if ($taggedHosts){

                Write-Verbose -Message "Hosts tagged with $($hostTag.tag) : $taggedHosts"
                New-HostGroup $taggedHosts $hostTag.hostGroup 

            } # Tagged Hosts loop

        } # Host Categories Loop

        foreach ($vmTag in $licCats){

            $selectedVms = Get-Cluster $cluster -Verbose:$false | Get-VM -Verbose:$false | Where-Object { $_.Guest.OSFullName -match $vmTag.tag }

            if ($selectedVms){

                Write-Verbose -Message "VMs tagged with $($vmTag.tag) : $selectedVms"
                New-VMGroup $selectedVms $vmTag.vmGroup 

            } # SelectedVMs loop
            
        } # VM Tagging Loop

        foreach ($item in $licCats){
            if ((Get-DrsClusterGroup -Cluster $cluster -Type VMHostGroup -Name $item.hostGroup -ErrorAction SilentlyContinue -Verbose:$false) -and (Get-DrsClusterGroup -Cluster $cluster -Type VMGroup -Name $item.vmGroup -ErrorAction SilentlyContinue -Verbose:$false)){
                $drsRule = Get-DrsVMHostRule -Cluster $cluster -Type ShouldRunOn -VMHostGroup $item.hostGroup -VMGroup $item.vmGroup
                if(!$drsRule){
                    
                    Write-Verbose -Message "Creating DRS rule for $($item.hostGroup) and $($item.vmGroup)"
                    New-DrsVMHostRule -Name $item.Name -Cluster $cluster -VMHostGroup $item.hostGroup -VMGroup $item.vmGroup -Type ShouldRunOn -Enabled:$false
                }
            }
        }

    } # Cluster Loop

 Disconnect-VIServer * -Confirm:$false -Verbose:$false

} # vCenter Loop
