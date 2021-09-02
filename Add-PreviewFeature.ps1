$subs = Get-AzSubscription | where {($_.state -ne 'Disabled')} #-and ($_.name -like '*dev*')}

foreach ($sub in $subs) {

    Select-AzSubscription $sub.name | out-null

    #Get-AzProviderFeature -FeatureName "AllowUpdateAddressSpaceInPeeredVnets" -ProviderNamespace "Microsoft.Network"

    $features = Get-AzProviderFeature -FeatureName "AllowUpdateAddressSpaceInPeeredVnets" -ProviderNamespace "Microsoft.Network"

    if ($features.RegistrationState -ne 'Registered'){

        Write-Host "$($sub.Name) $($features.RegistrationState)"

        #Register-AzProviderFeature -FeatureName "AllowUpdateAddressSpaceInPeeredVnets" -ProviderNamespace "Microsoft.Network"

    }
}

 
