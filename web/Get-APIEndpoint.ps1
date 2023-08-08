try {
    $response = Invoke-RestMethod -Uri "https://api.example.com/data" -Method Get

    # Check if the request was successful (200 OK)
    if ($response.StatusCode -eq 200) {
        Write-Host "Request successful!"
        Write-Host "Response content:"
        $response.Content
    } else {
        Write-Host "Request failed with status code $($response.StatusCode)"
    }
} catch {
    Write-Host "An error occurred: $($_.Exception.Message)"
}
