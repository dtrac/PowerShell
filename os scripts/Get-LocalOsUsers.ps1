    # Create computer object
    $computer = [ADSI]"WinNT://$computerName,computer"

    # Get local users list
    $userList = $computer.psbase.Children | Where-Object { $_.psbase.schemaclassname -eq 'user' } | Select Name

    Write-Host "`nComputer: " $computerName -ForegroundColor Green
    Write-Host ""
    foreach ($user in $userList) { Write-Host $user.Name -ForegroundColor White}
    Write-Host ""
