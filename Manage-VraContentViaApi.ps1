[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Get Auth Token
$url = “https://$($vraServer)/identity/api/tokens”
$properties = @{‘username’ = $username; ‘password’ = $password; ‘tenant’ = $tenant}
$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”}
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

$content = $request.content | convertFrom-json
$bearerToken = $content.id
Write-Verbose -Message  "Token: $bearerToken"

# get list of blueprints
$url = "https://$($vraServer)/content-management-service/api/contents?limit=80"
$headers = @{“Content-Type” = “application/json”; “Accept” = “application/json”; “Authorization” = “Bearer ${bearerToken}”}
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$requests = $request.Content | ConvertFrom-Json

<# get list of blueprint content types 

    component-profile-value
    xaas-blueprint
    property-definition
    property-group
    composite-blueprint
    xaas-resource-type
    xaas-resource-action
    xaas-resource-mapping

#>

$types = ($requests.content).contentTypeId | Select -Unique

# Get list of blueprint Ids
$ids = ($requests.content).Id 

#$ids = @("8c7ede8b-da83-45f0-a555-14bb20f5d1c1") # Windows only

# Component Profiles
$componentProfileIds = ($requests.content | Where {$_.contentTypeId -eq 'component-profile-value'}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'Component Profile Package'; ‘description’ = 'Component Profiles Only'; ‘contents’ = $componentProfileIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

# XaaS Blueprints
$xaasIds = ($requests.content | Where {$_.contentTypeId -eq 'xaas-blueprint'}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'XaaS Blueprints Package'; ‘description’ = 'XaaS Blueprints Only'; ‘contents’ = $xaasIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

# property-groups
$propertygroupIds = ($requests.content | Where {$_.contentTypeId -eq 'property-group'}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'Property Groups Package'; ‘description’ = 'Property Groups Only'; ‘contents’ = $propertygroupIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

# composite-blueprint
$compositeBlueprintIds = ($requests.content | Where {$_.contentTypeId -eq 'composite-blueprint'}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'Composite Blueprints Package'; ‘description’ = 'Composite Blueprints Only'; ‘contents’ = $compositeBlueprintIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

# property-definitions - SQL Server
$sqlpropertydefinitionIds = ($requests.content | Where {($_.contentTypeId -eq 'property-definition') -and ($_.contentId -match 'SQL*')}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'SQL Property Definition Package'; ‘description’ = 'SQL Property Definitions Only'; ‘contents’ = $sqlpropertydefinitionIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing


# property-definitions - Infrahosting
$infrahostingpropertydefinitionIds = ($requests.content | Where {($_.contentTypeId -eq 'property-definition') -and ($_.contentId -match 'Infrahosting*')}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'Infrahosting Property Definition Package'; ‘description’ = 'Infrahosting Property Definitions Only'; ‘contents’ = $infrahostingpropertydefinitionIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing




# property-definitions
$propertydefinitionIds = ($requests.content | Where {$_.contentTypeId -eq 'property-definition'}).Id

# Create a Content Package containing component profiles
$properties = @{‘name’ = 'Property Definition Package'; ‘description’ = 'Property Definitions Only'; ‘contents’ = $propertydefinitionIds}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing



# Create a Content Package containing all blueprints
$properties = @{‘name’ = 'Windows Server Package'; ‘description’ = 'Windows Server Only'; ‘contents’ = $ids}

$bodyObject = New-Object –TypeName PSObject –Property $properties
$body = $bodyObject | ConvertTo-Json

$url = "https://$($vraServer)/content-management-service/api/packages"
$request = Invoke-WebRequest $url -Method POST -Headers $headers -Body $body -UseBasicParsing

# Update package
$url = "https://$($vraServer)/content-management-service/api/packages/8a42c3be-71b8-46ef-9b77-f987b0dba90a"
$request = Invoke-WebRequest $url -Method PUT -Headers $headers -Body $body -UseBasicParsing

# List packages
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing
$packages = $request.Content | ConvertFrom-Json
$packages.content
$packageId = ($packages.content | Where {$_.name -eq 'Blueprint Package'}).Id

# Export contents to a zip file
$url = "https://$($vraServer)/content-management-service/api/packages/$packageId"
$headers = @{“Accept” = “application/zip”; “Authorization” = “Bearer ${bearerToken}”}
$request = Invoke-WebRequest $url -Method GET -Headers $headers -UseBasicParsing

