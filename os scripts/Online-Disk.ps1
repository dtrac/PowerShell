function Online-Disk {
[CmdletBinding()]
param(
    [string]$disk,
    [string]$file = 'C:\DiskPart.txt'
    )
        
        Set-Content $file "select disk $disk`nonline disk"
        Start-Process DiskPart.exe -ArgumentList "/s $file" -Wait -PassThru
        Remove-Item $file
}
#Usage: Online-Disk -disk 1
