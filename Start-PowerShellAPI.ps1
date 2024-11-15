# Define the API endpoint
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()

Write-Output "Listening on http://localhost:8080/..."

# Main loop to handle requests
while ($listener.IsListening) {
    try {
        # Wait for a request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Prepare a response
        $response.ContentType = "application/json"
        $response.StatusCode = 200

        # Define a simple response object
        $responseData = @{
            message = "Hello from PowerShell API!"
            timestamp = (Get-Date).ToString()
            method = $request.HttpMethod
            path = $request.Url.AbsolutePath
        }

        # Convert the response to JSON
        $jsonResponse = $responseData | ConvertTo-Json

        # Write the response
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.OutputStream.Close()
    }
    catch {
        Write-Error "Error processing request: $_"
    }
}

# Stop the listener when script ends (CTRL+C)
$listener.Stop()
