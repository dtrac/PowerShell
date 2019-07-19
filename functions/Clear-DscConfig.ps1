function ClearDscConfig {
    
    Remove-DscConfigurationDocument -Stage Pending -Force
    Remove-DscConfigurationDocument -Stage Current -Force
    
}
