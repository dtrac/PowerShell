$VerbosePreference = 'Continue'

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$catalogItem = 'Windows Server'

Write-Verbose -Message "vRA Instance: $env:vraServer"
Write-Verbose -Message "vRA Tenant: $env:tenant"
Write-Verbose -Message  "Catalog item: $catalogItem"
Write-Verbose -Message  "Image: $env:image"

<#
$images = @(
'ValueSet.WindowsServer2016Standard',
'ValueSet.WindowsServer2016Datacenter',
'ValueSet.WindowsServer2012R2Standard',
'ValueSet.WindowsServer2012R2Datacenter'
)
#>

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

# Get entitled catalog items
$url = “https://$($env:vraServer)/catalog-service/api/consumer/entitledCatalogItems/”
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”; “Authorization” = “Bearer ${bearerToken}”}
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$content = $request.Content | ConvertFrom-Json

# Filter for specific catalog item by name
$consumerEntitledCatalogItem = $content.content | ? { $_.catalogItem.name -eq $catalogItem }
Write-Verbose -Message  "CatalogItem: $consumerEntitledCatalogItem"
$consumerEntitledCatalogItemId = $consumerEntitledCatalogItem.catalogItem.id
Write-Verbose -Message  "CatalogItemId: $consumerEntitledCatalogItemId"

# Return the catalog item id
$url = “https://$($env:vraServer)/catalog-service/api/consumer/entitledCatalogItemViews/$($consumerEntitledCatalogItemId)”
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$content = $request.Content | ConvertFrom-Json

# Return the GET URL for this catalog item id
$requestTemplateURL = $content.links | ? { $_.rel -eq ‘GET: Request Template’ }
Write-Verbose -Message  "requestTemplateURL: $requestTemplateURL"

# Return the POST URL for this catalog item id
$requestPOSTURL = $content.links | ? { $_.rel -eq ‘POST: Submit Request’ }
Write-Verbose -Message  "requestPOSTURL: $requestPOSTURL"

#foreach ($image in $images) {

Write-Verbose -Message "Working on Image: $env:image"

# Return the template JSON
$request = Invoke-WebRequest $requestTemplateURL.href.Split("{")[0] -Method GET -Headers $headers -UseBasicParsing

# Update the template JSON
$req = $request.Content | ConvertFrom-Json

$req.data.'InfraHosting.Metadata.Application'='A0001-INFRAHOSTING'
$req.data.'InfraHosting.Metadata.Environment'='SIT'
$req.data.'InfraHosting.Metadata.EnvInstance'='1'
$req.data.'ReservationPolicyID'='e0e784cf-00cb-40af-bc91-bca049957b0f'
$req.data.vSphereVM_WinSvr.data.'InfraHosting.Platform'='waitrose_sip_profile::base_config'

$updatedReq = $req | ConvertTo-Json -Depth 9

# Request the VM
$request = Invoke-WebRequest $requestPOSTURL.href.Split("{")[0] -Method POST -Headers $headers -body $updatedReq -UseBasicParsing

#}

# Retrieve Deployment Progress
$req = $request.Content | ConvertFrom-Json
$start = Get-Date

while ($true){

    $status = Invoke-WebRequest “https://$($env:vraServer)/catalog-service/api/consumer/requests/$($req.id)" -Headers $headers -UseBasicParsing -Verbose:$false
    $request = $status.Content | ConvertFrom-Json
    if (($request.state -like "Successful") -or ($request.state -like "Failed") -or ($request.state -like "Provider_Failed")){
        break
    }
    $end = Get-Date
    $diff = New-Timespan -Start $start -End $end
    Write-Verbose -Message "Duration: $($diff.Minutes) Minutes and $($diff.Seconds) Seconds - Current Status $($request.state)"
    Start-Sleep 30

}

if ($request.state -like "Successful"){

    Write-Verbose -Message "Deployment Complete in $($diff.Minutes) Minutes and $($diff.Seconds) Seconds"
    $requestDetails = Invoke-WebRequest “https://$($env:vraServer)/catalog-service/api/consumer/requests/$($req.id)/resourceViews" -Headers $headers -UseBasicParsing
    $content = $requestDetails.Content | ConvertFrom-Json
    
$ipAddress = $content.content.data.ip_address
Write-Verbose -Message "ipAddress: $ipAddress"
"ipaddress=$ipAddress" | Out-File env.properties -Encoding ASCII

$machineName = $content.content.data.MachineName
Write-Verbose -Message "machineName: $machineName"
"machineName=$machineName" | Out-File env.properties -Encoding ASCII -Append

$requestId = $req.id
Write-Verbose -Message "requestId: $requestId"
"requestId=$requestId" | Out-File env.properties -Encoding ASCII -Append

}
else {

    Write-Error -Message "Deployment Failed in $($diff.Minutes) Minutes and $($diff.Seconds) Seconds"
}
