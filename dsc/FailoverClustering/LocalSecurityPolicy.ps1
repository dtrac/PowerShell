Configuration LocalSecurityPolicy
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SecurityPolicyDsc

    Node localhost
    {
        UserRightsAssignment VolumeMaintenanceTasks
        {
            Policy = 'Perform_volume_maintenance_tasks'
            Identity = 'Administrators'
            Force = $true
            }
    }
}
