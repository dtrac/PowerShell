$VerbosePreference = 'Continue'
Write-Verbose 'Destroying Machine...'

Write-Verbose -Message "machineName: $env:machineName"
Write-Verbose -Message "requestId: $env:requestId"
Write-Verbose -Message "machineName: $env:vraServer"
Write-Verbose -Message "requestId: $env:tenant"

# Define action
$action = 'virtual.Destroy'
Write-Verbose -Message "action: $action"

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Request login token

$url = “https://$($env:vraServer)/identity/api/tokens”
$properties = @{‘username’ = $env:username; ‘password’ = $env:password; ‘tenant’ = $env:tenant}
$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”}
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing
$content = $request.content | convertFrom-json
$bearerToken = $content.id
Write-Verbose -Message  "Token: $bearerToken"


# Get available Day 2 Actions

$url = “https://$($env:vraServer)/catalog-service/api/consumer/requests/$($env:requestId)/resourceViews”
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”; “Authorization” = “Bearer ${bearerToken}”}
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$requests = $request.Content | ConvertFrom-Json

$getURL = ($requests.content.links | Where {($_.rel -match 'virtual.Destroy') -and($_.rel -match 'GET') }).href
$postURL = ($requests.content.links | Where {($_.rel -match 'virtual.Destroy') -and($_.rel -match 'POST') }).href


# Get the JSON Template
$url = $getURL
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”; “Authorization” = “Bearer ${bearerToken}”}
$template = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$templateJson = $template.content | ConvertFrom-Json

# Request Day 2 Action

$url = $postURL
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”; “Authorization” = “Bearer ${bearerToken}”}
$template = Invoke-WebRequest $url -Method POST -Headers $headers -UseBasicParsing -Body $template

if ($template.StatusCode -eq '201'){

    Write-Verbose 'Day 2 Action request successful'
    exit 0
} 
else {
    Write-Error "Day 2 Action request unsuccessful - $($template.StatusCode)"
    exit 1
}
