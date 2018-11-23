function Online-Disk {
[CmdletBinding()]
param(
    [string]$driveLabel,
    [string]$driveLetter,
    [string]$disk,
    [string]$file = 'C:\DiskPart.txt'
    )
        
        Set-Content $file "select disk $disk`nonline disk"
        Start-Process DiskPart.exe -ArgumentList "/s $file" -Wait -PassThru
        Remove-Item $file
}
#Usage: Online-Disk -driveLabel 'Data' -driveLetter 'd' -disk 1
