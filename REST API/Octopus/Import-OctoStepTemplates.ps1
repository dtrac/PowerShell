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

# Import Action Templates
$jsonFiles = gci *-action-template.json

foreach ($jsonFile in $jsonFiles.Name){

    # Create an Action Template
    $body = Get-Content $jsonFile | ConvertFrom-Json

    $name = $jsonFile.Split("-")[0]
    "Working on $name..."
    
    $response = Post-OctopusResource "/api/actiontemplates" $body
}
