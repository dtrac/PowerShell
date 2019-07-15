$uri = 'https://www.ultramarathonrunningstore.com/GU-CARAMEL-COFFEE-STROOPWAFEL-Energy-Waffles-p/guwafflecc.htm'
$className = 'product_productprice' # Inspect element...

$response = Invoke-WebRequest -Uri $uri
$startingPrice = [decimal]1.85 # Set startiing price
$currentPrice = ($response.ParsedHtml.body.getElementsByClassName('$className') | Select textContent -First 1).textContent.split("£")[1]

while ([decimal]$currentPrice -eq $startingPrice){
    
    $response = Invoke-WebRequest -Uri $uri
    $startingPrice = [decimal]1.85
    $currentPrice = ($response.ParsedHtml.body.getElementsByClassName('product_productprice') | Select textContent -First 1).textContent.split("£")[1]
    
    "Checking price @ $(Get-Date)..."
    Start-Sleep -Seconds (60*60*6) # Every 6 hours
}

if ($currentPrice -lt $startingPrice){
    "Price has gone down to £$currentPrice"
}
elseif ($currentPrice -gt $startingPrice) {
    "Price has gone up to £$currentPrice"
}
