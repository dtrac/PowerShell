
  $verbosepreference = 'continue'

  $groupObj = [ADSI]"WinNT://./Administrators"
  
  Try {
      $groupObj.Add("WinNT://$adDomain/$domainGroup")
  }
  Catch {
      Write-Warning -Message "Adding $domainGroup to local Administrators group failed!"
  }
  
  $members = net localgroup administrators |
      Where-Object {$_ -AND $_ -notmatch "command completed successfully"} |
      Select-Object -skip 4
      
  if ($members -notcontains "$adDomain\$domainGroup"){

      Write-Warning -Message "Adding $domainGroup to local Administrators group failed!"

  }
  else {
      Write-Verbose -Message "$domainGroup is a member of local Administrators"
  }
