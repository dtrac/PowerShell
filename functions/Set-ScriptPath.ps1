function SetScriptPath {

    try {
        $scriptPath = $PSScriptRoot
        if (!$scriptPath)
        {
            if ($psISE)
            {
                $scriptPath = Split-Path -Parent -Path $psISE.CurrentFile.FullPath
            } else {
                Write-Host -ForegroundColor Red "Cannot resolve script file's path"
                exit 1
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "Caught Exception: $($Error[0].Exception.Message)"
        exit 2
    }
    return $scriptPath
}
$scriptPath = Set-ScriptPath
