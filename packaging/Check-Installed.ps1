function Check-Installed {
  [CmdletBinding()]
  param
  (
    [string]$program
    [string]$url = 'http://<Artefact Repo URL>/Visual_Cpp_2015_Redistributable_x64-14.0.23026.0.exe'
  )

  $x86 = ((Get-ChildItem -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall') |
      Where-Object { $_.GetValue( 'DisplayName' ) -like "*$program*" } ).Length -gt 0

  $x64 = ((Get-ChildItem -Path 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') |
      Where-Object { $_.GetValue( 'DisplayName' ) -like "*$program*" } ).Length -gt 0
      
    return $x86 -or $x64

  }

# Example Usage - Visual C++ Redistributable:
$installed = Invoke-Command -Session $session -ScriptBlock ${function:Check-Installed} -Argumentlist 'Microsoft Visual C++ 2015 x64 Minimum Runtime - 14.0.23026'

if ($installed -ne $True){
    Write-Verbose -Message 'Downloading Visual C++ ...'
        Invoke-Command -Session $session -ScriptBlock {Invoke-Webrequest -uri $using:url -Outfile "$env:TEMP\$using:visualC"}

    Write-Verbose -Message 'Installing Visual C++ ...'
        Invoke-Command -Session $session -ScriptBlock {Start-Process -FilePath "$env:TEMP\$using:visualC" -ArgumentList '/install /passive /norestart' -Wait -PassThru}

} else { 

    Write-Verbose -Message 'Visual C++ is already installed...' 
    
}
