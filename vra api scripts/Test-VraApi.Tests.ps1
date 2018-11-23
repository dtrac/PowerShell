Describe 'Testing vRA API' {

    $params = @{
        vraServer = 'server.local'
        tenant = 'compute'
        username = 'serviceaccount@local'
        password = 'passw0rd'
        contentType = 'application/json'
        catalogItemId = 'rand0m-5tr1ng'
        apitoken = $null
    }

    $headers = @{
        "Accept" = "application/json"
    }
    
    Context 'Testing vRA API'{

        <#
        it 'Write Out Variables'{

            Write-Host "$($params.vraServer)"
            Write-Host "$($params.tenant)"
            Write-Host "$($params.username)"
            Write-Host "$($params.password)"
            Write-Host "$($params.headers)"
        }
        #>

        it 'Can generate a token'{

            $properties = @{'username' = $($params.username); 'password' = $($params.password); 'tenant' = $($params.tenant)}

            $response = Invoke-WebRequest -Uri "https://$($params.vraServer)/identity/api/tokens" `
                                -Method POST `
                                -Headers $params.headers `
                                -ContentType $params.contentType `
                                -Body ($properties | ConvertTo-Json) `
                                -UseBasicParsing

            $content = $response | ConvertFrom-Json
            $content.id | Should Not BeNullOrEmpty

            $params.apiToken = $content.id
        }

        it 'Can return a list of catalog items'{

            $headers.Authorization = "Bearer $($params.apiToken)"
            Write-Host "headers: $headers"
            Write-Host "contentType: $contentType"

            $response = Invoke-WebRequest -Uri "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItems" `
                                -Method GET `
                                -Headers $headers `
                                #-UseBasicParsing
                                #-ContentType $contentType `


            $catItems = $response.Content | ConvertFrom-Json
            $catItems.content.length | Should -BeGreaterThan 1
        }

        it 'Can return a specific catalog item id'{

            $headers.Authorization = "Bearer $($params.apiToken)"

            $response = Invoke-WebRequest -Uri "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItems" `
                                -Method GET `
                                -Headers $headers `
                                #-ContentType $contentType `
                                #-UseBasicParsing

            $catItems = $response.Content | ConvertFrom-Json
            $consumerEntitledCatalogItem = $catItems.content | Where-Object { $_.catalogItem.name -eq 'Windows Server' }
            $consumerEntitledCatalogItem.catalogItem.id | Should -Be $params.catalogItemId

        }

        it 'Can return a specific catalog item GET URL'{

            $headers.Authorization = "Bearer $($params.apiToken)"

            $response = Invoke-WebRequest -Uri "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItemViews/$($params.catalogItemId)" `
                                -Method GET `
                                -Headers $headers `
                                #-ContentType $contentType `
                                #-UseBasicParsing

            $content = $response.Content | ConvertFrom-Json
            $result = $content.links | Where-Object { $_.rel -eq 'GET: Request Template' }
            $result.href | Should -Be "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItems/$($params.catalogItemId)/requests/template"

        }

        it 'Can return a specific catalog item POST URL'{

            $headers.Authorization = "Bearer $($params.apiToken)"

            $response = Invoke-WebRequest -Uri "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItemViews/$($params.catalogItemId)" `
                                -Method GET `
                                -Headers $headers `
                                #-ContentType $contentType `
                                #-UseBasicParsing

            $content = $response.Content | ConvertFrom-Json
            $result = $content.links | Where-Object { $_.rel -eq 'POST: Submit Request' }
            $result.href | Should -Be "https://$($params.vraServer)/catalog-service/api/consumer/entitledCatalogItems/$($params.catalogItemId)/requests"

        }
    }
}
