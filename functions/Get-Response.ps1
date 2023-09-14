function yN {
    <#
    .SYNOPSIS
    Prompts for a yes/no answer to a question
    .PARAMETER prompt
    Prompt text to display to user (required)
    .OUTPUTS
    Returns $true if yes and $false if no
    #> 
    param([Parameter(Mandatory=$true)][string] $prompt)
    while ($true) {
        $conf = Read-Host "$prompt (y/n)"
        switch ($conf.ToLower()) {
            "n" {return $false}
            "y" {return $true}
        }
    }
}
