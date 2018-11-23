<#
.NAME
	Add-ToSCCMCollection.ps1
.SYNOPSIS
	Takes parameter input (e.g. from vRO), adds SCCM PowerShell Modules and adds a computer object to an SCCM collection.
.AUTHOR
	Dan Tracey
.DATE
	27 / 04 / 2016
.VERSION
	1.0
.CHANGELOG
	27 / 04 / 2016 - v1.0 - Initial Script (DanT)
#>

param(
[string]$computerName,
[string]$sccmCollection,
[string]$username,
[securestring]$password
)

# Create PS Credential
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$password
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Force the computer name to upper case. Makes comparison easier
$computerName = $computerName.toUpper();

# Add Computer to SCCM Collection
Invoke-Command -Authentication CredSSP -Credential $cred -ComputerName "$env:COMPUTERNAME.$env:USERDNSDOMAIN" -UseSSL -Port 5986 -SessionOption $so {

	# Preparing SCCM environment
	Import-Module -Name "$(Split-Path $Env:SMS_ADMIN_UI_PATH)\ConfigurationManager.psd1" ;
	Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -Verbose ;

	# Check existing Device Membership
	Write-Host "Checking Device Membership - $using:computerName in $using:sccmCollection"

		# Create array of objects
		$objects = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $using:sccmCollection | Select Rulename
		#Write-Host $objects

	    # Check any obejcts returned
		if ($objects) {

		    # Create array of strings
		    $strings = $objects | foreach {$_.Rulename.toUpper()}
		    #Write-Host $strings

		    # Perform the check
		    if ($strings.Contains("$using:computerName") -eq $false){

			    # Add to Device Collection
			    Write-Host "Adding $using:computerName to $using:sccmCollection"
			    Add-CMDeviceCollectionDirectMembershipRule -CollectionName $using:sccmCollection -ResourceId $(Get-CMDevice -Name $using:computerName | Where-Object {$_.IsActive -eq $true}).ResourceID -Verbose
			    Write-Host "Added $using:computerName to $using:sccmCollection" -ForegroundColor Green
		    }
		    else {
		        Write-Host "$using:computerName is already in $using:sccmCollection" -ForegroundColor Green
		    }
		}
		else {
		    # No objects were returned.  The VM cannot therefore already be a member of the colleciton
			# Add to Device Collection
			Write-Host "This is an empty collection. Adding $using:computerName to $using:sccmCollection"
			Add-CMDeviceCollectionDirectMembershipRule -CollectionName $using:sccmCollection -ResourceId $(Get-CMDevice -Name $using:computerName).ResourceID -Verbose
			Write-Host "Added $using:computerName to $using:sccmCollection" -ForegroundColor Green

		}

}
