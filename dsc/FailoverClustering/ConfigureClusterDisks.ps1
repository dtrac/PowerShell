Configuration 'ConfigureClusterDisks' 
{
    
    Import-DscResource -ModuleName StorageDsc
    Import-DscResource -ModuleName xFailoverCluster

    $DiskConfiguration = $Node.DiskConfiguration

    OpticalDiskDriveLetter SetFirstOpticalDiskDriveLetterToZ
    {
        DiskId      = 1
        DriveLetter = 'Z'
    }

    foreach ($Disk in $DiskConfiguration)
    {
        WaitForDisk $Disk.Label
        {
             DiskId = $Disk.Number
             RetryIntervalSec = $Disk.RetryInterval
             RetryCount = $Disk.RetryCount
             DependsOn = "[Disk]$($Disk.Label)"
        }
    
        Disk $Disk.Label
        {
             DiskId = $Disk.Number
             DriveLetter = $Disk.Letter
             FSFormat = $Disk.Format
             FSLabel = $Disk.Label
             AllocationUnitSize = 64KB
             AllowDestructive = $true
             ClearDisk = $true
        }
    }
}
