# PowerShell Vars
$VerbosePreference = 'Continue'

# Octopus Vars
$OctopusServer = 'ServerName'
$APIKey = 'API-123456789ABCDEFGH' 

$baseUri = "http://$OctopusServer"
$header = @{ "X-Octopus-ApiKey" = $APIKey }

#region Functions
function Get-OctopusResource([string]$uri) {
    Write-Host "[GET]: $uri"
    return Invoke-RestMethod -Method Get -Uri "$baseUri/$uri" -Headers $header
}

function Put-OctopusResource([string]$uri, [object]$resource) {
    Write-Host "[PUT]: $uri"
    Invoke-RestMethod -Method Put -Uri "$baseUri/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $header
}

function Post-OctopusResource([string]$uri, [object]$resource) {
    Write-Host "[POST]: $uri"
    Invoke-RestMethod -Method Post -Uri "$baseUri/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $header
}

function Delete-OctopusResource([string]$uri, [object]$resource) {
    Write-Host "[DELETE]: $uri"
    Invoke-RestMethod -Method Delete -Uri "$baseUri/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $header
}
#endregion Functions

# Import Variable Sets
$jsonFiles = gci *-var-set.json
foreach ($jsonFile in $jsonFiles.Name){

    $name = $jsonFile.Split("-")[0]
    "Working on $name..."
    
    # Create a variable set
    $body = @{ Name = $name }
    $response = Post-OctopusResource "/api/libraryvariablesets" $body
    $variableSet = Get-OctopusResource $response.Links.Variables

    # Poplulate variable set
    $body = Get-Content $jsonFile | ConvertFrom-Json

        $body.Variables | ForEach-Object {
            $variable = [PSCustomObject]@{
                    Name = $_.Name
                    Value = $_.Value
                    Type = $_.Type
                }
        $variableSet.Variables += $variable
        }

Put-OctopusResource $variableSet.Links.Self $variableSet
}
