function Write-Log
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
        ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$Message,

        [Parameter(Mandatory=$false)] 
        [ValidateSet("Info","Warning","Error")] 
        [string]$Level="Info",

        [Parameter(Mandatory=$false)] 
        [string]$FileName = "$(Get-Date -f yyyy-MM-dd).log",

        [Parameter(Mandatory=$false)] 
        [string]$Path = (Join-Path -Path "$([System.Environment]::GetEnvironmentVariable('TEMP','Machine'))" -ChildPath $FileName), 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 

        $VerbosePreference = 'Continue' 
        
        # Format Date for log entries
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path..." 
            New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing yet. 
            } 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warning' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
        # Nothing yet
    } 
}
