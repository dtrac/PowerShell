## Azure Basics

# Configure PowerShell:
Install-Module AzureRM.NetCore # or...
Update-Module -Name AzureRM.NetCore

# Import AzureRM PowerShell Module:
Import-Module AzureRM.NetCore

# Connect to Azure:
Connect-AzureRmAccount

# Change Subscription:
Select-AzureRmSubscription -Subscription $subscription

# Retreive a list of Resource Groups:
Get-AzureRmResourceGroup | Format-Table

# Create Resource Group:
New-AzureRmResourceGroup -Name $rgName -Location $location

# List Azure resources:
Get-AzureRmResource | Format-Table

# List Azure resources from specific Resource Group:
Get-AzureRmResource -ResourceGroup $rgName

# Create Azure VM:
New-AzureRmVm -ResourceGroupName $rgName `
              -Name $vmName `
              -Credential $credObj `
              -Location $location `
              -Image $vmImage `

# Manage Azure VM State:
Remove-AzureRmVM	# Deletes an Azure VM.
Start-AzureRmVM	    # Start a stopped VM.
Stop-AzureRmVM	    # Stop a running VM.
Restart-AzureRmVM	# Restart a VM.

# Manage Azure VM Config - e.g. REsize VM:
$vm = Get-AzureRmVM  -Name $vmName -ResourceGroupName $rgName
$vm.HardwareProfile.vmSize = "Standard_DS3_v2"
Update-AzureRmVM -ResourceGroupName $rgName  -VM $vm