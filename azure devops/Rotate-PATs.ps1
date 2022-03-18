
# Payload is an event grid trigger - read off secret (PAT) name, expiry and svc_acc name
$PATNAME = 'test1'
$Expiry = (Get-Date).AddDays(90).ToString('yyyy-MM-dd')


if ($PATNAME[-1] -eq "1"){
    $NEWNAME = $PATNAME.Replace("1","2")
} elseif ($PATNAME[-1] -eq "2") {
    $NEWNAME = $PATNAME.Replace("2","1")
} else {
    Write-Error "PAT name suffix should be 1 or 2 for rotation!"
}

# Connect as svc acc
[securestring]$SecuredPassword = ConvertTo-SecureString $ENV:PASSWORD -AsPlainText -Force
[pscredential]$Credential = New-Object -TypeName System.Management.Automation.PSCredential ($ENV:USER, $SecuredPassword)
Connect-AzAccount -TenantId $ENV:TENANTID -Credential $Credential

# Get ADO Access token
$token = (Get-AzAccessToken -ResourceUrl "499b84ac-1321-427f-aa17-267ca6975798").Token

#region functions
# List all ADO Pat Tokens
function List-PATs {
    $URL = "https://vssps.dev.azure.com/$($ENV:ORGANIZATION)/_apis/tokens/pats?api-version=7.1-preview.1"
    $header = @{
        'Authorization' = 'Bearer ' + $token
        'Content-Type' = 'application/json'
    }
    $patTokens = (Invoke-RestMethod -Method GET -Uri $URL -Headers $header).patTokens

    return $patTokens
}

function Get-PAT ($targetToken) {
    $URL = "https://vssps.dev.azure.com/$($ENV:ORGANIZATION)/_apis/tokens/pats?authorizationId=$($targetToken.authorizationId)&api-version=7.1-preview.1"
    $header = @{
        'Authorization' = 'Bearer ' + $token
        'Content-Type' = 'application/json'
    }
    $patToken = (Invoke-RestMethod -Method GET -Uri $URL -Headers $header).patToken

    return $patToken
}

function Create-PAT ($targetToken, $NEWNAME, $expiry) {
    $URL = "https://vssps.dev.azure.com/$($ENV:ORGANIZATION)/_apis/tokens/pats?api-version=7.1-preview.1"
    $header = @{
        'Authorization' = 'Bearer ' + $token
        'Content-Type' = 'application/json'
    }
    $body = @{
        'allOrgs'     = $false
        'displayName' = $NEWNAME
        'scope'       = $targetToken.scope
        'validTo'     = $expiry
    }
    $newToken = (Invoke-RestMethod -Method POST -Uri $URL -Headers $header -Body ($body | ConvertTo-Json)).patToken

    return $newToken
}

function Revoke-PAT ($targetToken) {
    $URL = "https://vssps.dev.azure.com/$($ENV:ORGANIZATION)/_apis/tokens/pats?authorizationId=$($targetToken.authorizationId)&api-version=7.1-preview.1"
    $header = @{
        'Authorization' = 'Bearer ' + $token
        'Content-Type' = 'application/json'
    }

    $result = (Invoke-RestMethod -Method DELETE -Uri $URL -Headers $header).patToken

    return $result
}
#endregion functions

# Return all PAT tokens
$patTokens = List-PATs

# Rotate target token
$targetToken = $patTokens | Where-Object {$_.displayName -eq $PATNAME}
$newToken = Create-PAT -targetToken $targetToken -NEWNAME $NEWNAME -expiry $Expiry

# Update Key Vault with new token

# Revoke old token
$result = Revoke-PAT -targetToken $targetToken

