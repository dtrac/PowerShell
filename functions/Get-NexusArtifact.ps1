function Get-NexusArtifact {
    Param(
    
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$component,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$type,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$version,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$group,

        [Parameter(Mandatory=$false)]
        [String]$targetDir = "C:\Windows\Temp",

        [Parameter(Mandatory=$false)]
        [String]$targetName = $component,
        
        [Parameter(Mandatory=$false)]
        [String]$nexusInstance = '10.0.0.1',
        
        [Parameter(Mandatory=$false)]
        [String]$nexusRepo = 'repositoryName'

    )

    $ProgressPreference = 'SilentlyContinue'
    $VerbosePreference = 'Continue'

    Write-Output "`nDownloading artifact:`n `nComponent: $component `nVersion: $version `nGroup: $group`n"

    $url = "http://$nexusInstance:8081/repository/$nexusRepo/$group/$component/$version/$component-$version.$type"

    (New-Object System.Net.WebClient).DownloadFile($url, "$targetDir\$targetName.$type")

    If (!(Test-Path $targetDir\$targetName.$type)) {
        Write-Error "Download of $component artifact failed!"
    }

    if ($component -ne $targetName){
        Write-Output "Renamed $component.$type to $targetName.$type"
    }
}
