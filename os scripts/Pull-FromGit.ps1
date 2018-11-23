<#
.SYNOPSIS
   Pull-FromGit provides the capability to perform a 'pull' from a git repository.
.DESCRIPTION
   When provided with git credentials and repo details, Pull-FromGit provides the capability to perform a 'pull' from a git repository.
.NOTES
   File Name  : Pull-FromGit.ps1
   Author     : Dan Tracey
   Version    : 1.0
.INPUTS
   Git credentials and repository name
.OUTPUTS
   An updated, merged local repository
.PARAMETER gitUser
   User name of the git user with sufficient permissions to perform a pull of the given repository.
.PARAMETER gitPass
   Password of the git user with sufficient permissions to perform a pull of the given repository.
.PARAMETER gitRepo
   Given repository from which to perform the pull.
#>

[CmdletBinding()]
param(
[string]$gitUser,
[string]$gitPass,
[string]$gitRepo,
[string]$localRepo
)
$VerbosePreference = 'Continue'

Write-Verbose -Message "Local repo is $localRepo..."

$gitCmd = "$env:ProgramW6432\git\cmd\git.exe"
Write-Verbose -Message "Git Command is $gitCmd..."

Write-Verbose -Message 'Configuring git settings...'
$ArgumentList = 'config --global http.sslVerify false'
Start-Process -FilePath $gitCmd -ArgumentList $ArgumentList -Wait -NoNewWindow -WorkingDirectory $localRepo

Write-Verbose -Message 'Performing git pull...'
$ArgumentList = "pull https://" + $gitUser + ":" + $gitPass + "@" + $gitRepo + ".git"
Start-Process -FilePath $gitCmd -ArgumentList $ArgumentList -Wait -NoNewWindow -WorkingDirectory $localRepo
