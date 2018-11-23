<#
.NAME
	Add-DnsRecord.ps1
.SYNOPSIS
	Takes parameter input (e.g. from vRO), adds DNS A record for a given hostname.
.AUTHOR
	Dan Tracey
.DATE
	05 / 10 / 2017
.VERSION
	1.0
.CHANGELOG
	05 / 10 / 2017 - v1.0 - Initial Script (DanT)
#>

param(
[string]$computerName,
[string]$ip,
[string]$dnsServer,
[string]$dnsZone,
[string]$username,
[securestring]$password
)

$VerbosePreference = "Continue"

# Create PS Credential
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$password

# Create PS Session Options 
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Split the IP address into its consituant parts
$octet = $ip.split("{.}")
if ($dnsZone -eq "trace.local") {

    # Logic for if one day we need to cope with multiple subnets but currently only 10.1.13.0
	# have three octet reverse lookup zones
    $subNets = @("13")
    if($octet[2] -in $subNets) {
	    Write-Verbose -Message "Using three octet reverse zone"
	    # Handle the zone reverse zone 13.1.10
	    $reverseZone = $octet[2] + "." + $octet[1] + "." + $octet[0] + ".in-addr.arpa"
	    $reverseIP = $octet[3]
	}
	else {
		Write-Verbose -Message "Using two octet reverse zone"
        $reverseZone = $octet[1] + "." + $octet[0] + ".in-addr.arpa"
	    $reverseIP = $octet[3] + "." + $octet[2]
	}
}
else {
    $reverseZone = $octet[0] + ".in-addr.arpa"
    $reverseIP = $octet[3] + "." + $octet[2] + "." + $octet[1]
}

$fqdn = $computerName + "." +  $dnsZone

# Get the Reverse lookup zone 
# Add DNS Forward Record
Write-Verbose -Message "Adding $computerName to $dnsZone zone on DNS Server: $dnsServer"
$output = Invoke-Command -Authentication CredSSP -Credential $cred -ComputerName "$env:COMPUTERNAME.$env:USERDNSDOMAIN" -UseSSL -Port 5986 -SessionOption $so {
		dnscmd.exe $using:dnsServer /RecordAdd $using:dnsZone $using:computerName A $using:ip
		}

if ($output -like "*Command completed successfully*")
	{	
		Write-Verbose -Message "$output"
		Write-Verbose -Message "Successfully added $computerName to $dnsZone on $dnsServer"
	}
elseif ($output -like "*DNS_ERROR_RECORD_ALREADY_EXISTS*")
	{
		Write-Verbose -Message "$output"
		Write-Warning "Manually remove the DNS record and try again"
	}
else
	{
		Write-Verbose -Message "$output"
		Write-Warning "Error adding $computerName to $dnsZone zone on DNS Server: $dnsServer"

	}
	
Write-Verbose -Message "Adding $reverseIP to $dnsZone zone on $reverseZone Server: $dnsServer"
$output = Invoke-Command -Authentication CredSSP -Credential $cred -ComputerName "$env:COMPUTERNAME.$env:USERDNSDOMAIN" -UseSSL -Port 5986 -SessionOption $so {
		dnscmd.exe $using:dnsServer /RecordAdd $using:reverseZone $using:reverseIP PTR $using:fqdn
		}

if ($output -like "*Command completed successfully*")
	{	
		Write-Verbose -Message "$output"
		Write-Verbose -Message "Successfully added $computerName to $dnsZone on $dnsServer"
		exit 0
	}
elseif ($output -like "*DNS_ERROR_RECORD_ALREADY_EXISTS*")
	{
		Write-Verbose -Message "$output"
		Write-Warning "Manually remove the DNS record and try again"
	}
else
	{
		Write-Verbose -Message "$output"
		Write-Warning "Error adding $computerName to $dnsZone zone on DNS Server: $dnsServer"

	}
		
	
