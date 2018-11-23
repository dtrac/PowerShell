function Configure-Disk {
[CmdletBinding()]
param(
    [string]$driveLabel,
    [string]$driveLetter,
    [string]$disk,
    [string]$file = 'C:\DiskPart.txt'
)
   
    Set-Content $file "select disk $disk"
    Add-Content $file "`nattribute disk clear readonly"
    Add-Content $file "`ncreate partition primary align=1024"
    Add-Content $file "`nassign letter=$driveLetter"
    Add-Content $file "`nformat fs=ntfs unit=64K label=$driveLabel quick"
    Start-Process DiskPart.exe -ArgumentList "/s $file" -Wait -PassThru
    
    Remove-Item $file

}
#Usage: Configure-Disk -driveLabel 'Data' -driveLetter 'd' -disk 1
