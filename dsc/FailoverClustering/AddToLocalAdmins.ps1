Configuration 'AddToLocalAdmins'
{
    Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]$BuildCreds
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost
    {
        xGroupSet AddUsersToLocalAdminsGroup
        {
            GroupName            = "Administrators"
            MembersToInclude     = $Node.LocalAdmins
            Credential           = $BuildCreds
        }                  
    }
}
