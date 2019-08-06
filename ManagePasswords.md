# Manage Passwords
## Create an encrypted password
```
$encPw = Read-Host -Prompt 'Enter password' -AsSecureString
$encPw
```
## Decrypting a secure password
```
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($encPw))
$pw
```
## ...store as an xml file
```
$encPw | Export-Clixml -Path 'C:\Password.xml'
```

## Create a single set of creds interactively
```
$creds = Get-Credential -Message 'Enter creds'
$creds
```

## Create a single set of creds with a password string
```
$secPass = ConvertTo-SecureString -String $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($OctopusParameters[$user,$secPass)
```

## ...and store as an xml file.
```
$creds | Export-Clixml -Path 'C:\creds.xml'
$credXml = Import-Clixml -Path 'C:\creds.xml'
```
## Decrypting a secure password from creds
```
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds.Password))
$pw
```
## or
```
$pw = $creds.GetNetworkCredential().Password
$pw
```
## Create a hashtable of cred input
```
$hash = @{
    'user1' = Get-Credential -Message 'Enter password for user1' -UserName user1
    'user2' = Get-Credential -Message 'Enter password for user2' -UserName user2
}
```
## ...and store as an xml file.
```
$hash | Export-Clixml -Path 'C:\multicreds.xml'
$hashXml = Import-Clixml -Path 'C:\multicreds.xml'
```
## NOTE: cred file can only be opened by the same user on the same system.
