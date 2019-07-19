function CreateCreds {
    
    Param(
    [Parameter(Mandatory=$false)]
    [ValidateNotNullorEmpty()]
    [String]$user = "NoUserNeeded",

    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [String]$password
    )

    $secPass = ConvertTo-SecureString -String $password -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential($user,$secPass)

    Return $creds
}

# Usage:
# $Creds = CreateCreds -user UserName -password 'P@ssword123'
