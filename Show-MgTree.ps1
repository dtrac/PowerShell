function Show-MgTree {
    param(
        [string]$GroupName = "mg-production",
        [string]$Indent = ""
    )

    $mg = Get-AzManagementGroup -GroupName $GroupName -Expand
    Write-Host "$Indent$($mg.DisplayName) [$($mg.Name)]"

    # List subscriptions in this management group
    $subs = Get-AzManagementGroupSubscription -GroupName $mg.Name -ErrorAction SilentlyContinue
    foreach ($sub in $subs) {
        Write-Host "$Indent  └─ Subscription: $($sub.DisplayName) [$($sub.Id)]"
    }

    # Recurse into child management groups
    foreach ($child in $mg.Children | Where-Object { $_.Type -eq "Microsoft.Management/managementGroups" }) {
        Show-MgTree -GroupName $child.Name -Indent ("$Indent  ")
    }
}

$parentManagementGroups = @("mg-development", "mg-nonproduction", "mg-production")
foreach ($parent in $parentManagementGroups) {
    Show-MgTree -GroupName $parent
}
