$creds = Get-Credential

ipmo vmware.vimautomation.core

$vcenters = @(
    "vc1.domain.local",
    "vc2.domain.local"
)

Disconnect-VIServer * -Confirm:$false -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

foreach ($vc in $vcenters){
    
    Connect-VIServer $vc -Credential $creds

    Write-Output "======================"

    $templates = Get-Template Windows*
    $sorted = $templates | Sort

    foreach ($template in $sorted){

        $template.ExtensionData.Config.Annotation
        $templateDate = [datetime]$template.ExtensionData.Config.Annotation.Split(":")[1].Trim()
        if ($templateDate -lt (Get-Date).AddDays(-14)){
            Write-Warning "$($template.Name) is older than 14 days"
        }

    }

    if ($templates.Count -lt 7){
        
        Write-Warning "There are less than the expected number of templates"
    }
   
    Write-Output "======================"

    Disconnect-VIServer $vc -confirm:$false
   
}
