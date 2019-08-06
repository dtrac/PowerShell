#requires -Version 5.1
#requires -Modules ActiveDirectory

#region variables
$domainAdminCreds = Get-Credential -Message "Enter creds with permissions to create AD users and groups"
$userCsv = Import-Csv .\Users.csv # Path to .csv file containing user information - Resource Name, User Account, (initial) Password, Parent OU
$groupsCsv = Import-Csv .\Groups.csv # Path to .csv file containing group information - Group Name, Parent OU, Members
$pmpServer= 'dev-dt-ad.local'
$pmpToken = '<Redacted>'
#endregion variables

#region functions
function Get-PasswordFromPmp {

[CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][String]$pmpServer,
        [Parameter(Mandatory = $true)][String]$pmpToken,
        [Parameter(Mandatory = $true)][String]$pmpResource,
        [Parameter(Mandatory = $true)][String]$pmpAccount
    )



#region allow all protocols and certs
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#endregion allow all protocols and certs

$baseUri = "https://$($pmpServer):7272/restapi/json/v1"
$header = @{ "AUTHTOKEN" = $pmpToken }

function Get-PmpResource([string]$uri) {
    Write-Host "[GET]: $uri"
    return Invoke-RestMethod -Method Get -Uri "$baseUri/$uri" -Headers $header
}

try {

    Write-Progress -PercentComplete 0 -Activity "Starting Get-PasswordFromPmp for $pmpAccount..."

    # Get matching Resource
    $resourceId = ((Get-PmpResource 'resources').operation.Details | Where-Object {$_."RESOURCE NAME" -eq $pmpResource})."RESOURCE ID"
    Write-Progress -PercentComplete 33 -Activity "Getting matching Resource: $pmpResource..."
    Write-Verbose "`$resourceId: $resourceId"

    # Get matching Account
    $passwordId = ((Get-PmpResource "resources/$resourceId/accounts").operation.Details."ACCOUNT LIST" | Where-Object {$_."ACCOUNT NAME" -eq $pmpAccount}).PASSWDID
    Write-Progress -PercentComplete 66 -Activity "Getting matching Account: $pmpAccount..."
    Write-Verbose "`$passwordId: $passwordId"

    # Get Password
    $operation = (Get-PmpResource "resources/$resourceId/accounts/$passwordId/password").operation
    Write-Progress -PercentComplete 100 -Activity "Getting Account Password for $pmpAccount..."
    Write-Verbose "`$operation: $operation"

    if ($operation.result.status -eq "Success") {
        Write-Output $operation.Details.Password
    } 
    else {
          throw
         }
    }
    catch {
        throw "Error trying to get password for account $($pmpAccount) and resource $($pmpResource)"
    }
}
#endregion functions

#region script
# Create Users
$count = $userCsv.Count
$i = 0
foreach ($obj in $userCsv){

    Write-Progress -PercentComplete ($i*100/$count) -Activity "Working on $($obj.'Resource Name') $($obj.'User Account')..."
    "Working on $($obj.'User Account')..."
    $pmpPassword = Get-PasswordFromPmp -pmpResource $obj.'Resource Name' -pmpAccount $obj.'User Account' -pmpServer $pmpServer -pmpToken $pmpToken
    New-ADUser -Credential $domainAdminCreds `
               -Name $obj.'User Account' `
               -SamAccountName $obj.'User Account' `
               -UserPrincipalName $obj.'User Account' `
               -AccountPassword (ConvertTo-SecureString -String $pmpPassword -AsPlainText -Force) `
               -Path $obj.'OU' `
               -PassThru | Enable-ADAccount

}

# Create Groups
$count = $groupsCsv.Count
$i = 0
foreach ($obj in $groupsCsv){

    Write-Progress -PercentComplete ($i*100/$count) -Activity "Working on $($obj.'Group Name')..."
    "Working on $($obj.'Group Name')..."

    if ($obj.Members -ne $null){

    $members = $obj.Members.Split(",")
    
    New-ADGroup -Credential $domainAdminCreds `
                -Name $obj.'Group Name' `
                -DisplayName $obj.'Group Name' `
                -GroupCategory Security `
                -GroupScope Global `
                -Path $obj.'OU' `
                -PassThru | Add-ADGroupMember -Members $members
                }
    else {

    New-ADGroup -Credential $domainAdminCreds `
                -Name $obj.'Group Name' `
                -DisplayName $obj.'Group Name' `
                -GroupCategory Security `
                -GroupScope Global `
                -Path $obj.'OU'
    }

}
#endregion script
