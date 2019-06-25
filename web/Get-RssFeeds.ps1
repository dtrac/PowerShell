# Download RSS Feed two ways!

$url = 'https://devblogs.microsoft.com/powershell/feed/'

# With .Net Web Client
([xml] [System.Net.WebClient]::new().
    DownloadString($url)).
        RSS.Channel.Item |
            Format-Table title,link


# With Invoke-WebRequest
$r = Invoke-WebRequest $url
([xml]$r.Content).rss.channel.Item | Format-Table title, link
