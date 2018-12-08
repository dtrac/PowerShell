# Testing Try/Catch

try {
    Get-Service doesNotExist -ErrorAction Stop
}
catch [System.Management.Automation.SessionStateException] {
    Write-Warning "Failed to find the thing"
    $_.exception.message
}
catch {
    Write-Warning -Message "Second Catch Block"
    $_.exception.message
}
finally {
    Write-Verbose "Always do this!!!"
}