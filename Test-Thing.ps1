
		$timeout = new-timespan -Seconds 120
		$sw = [diagnostics.stopwatch]::StartNew()
		while (($sw.elapsed -lt $timeout) -and ($success -ne $true)) {
			try {
				   Test-Thing -ErrorAction Stop
				   Write-Verbose -Message "Thing happened"
				   $success = $true
					
                } 
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] { # Specific error - $Error[0].Exception.GetType().FullName
                   Write-Warning -Message "Thing didn't happen in $([math]::Round($sw.elapsed.TotalSeconds)) seconds."
                   start-sleep -seconds 5
                }
            finally {
                if ($success){
                    Write-Verbose -Message "Success!"
                }
                else {
                    Write-Verbose -Message "Failure!"
                }
            }
		}
