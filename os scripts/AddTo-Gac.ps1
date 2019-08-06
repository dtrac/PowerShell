<#
    .NAME
        AddTo-Gac.ps1
    .SYNOPSIS
        Uses PowerShell DSC to add .dlls to the .Net Global Assembly Cache
    .AUTHOR
        Dan Tracey
    .DATE
        25 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        25 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'AddToGac' 
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node localhost
        {
            $fileList = @(Get-ChildItem -Path $Node.DllFolder -Recurse *.dll | Select-Object -ExpandProperty FullName)
            $gacPath = 'C:\Windows\Microsoft.NET\assembly\GAC_MSIL'

            foreach ($file in $fileList) {

                $folderName = (Get-Item $file).BaseName

                Script $folderName
                {
                    SetScript = {

                        # Load System.EnterpriseServices assembly
	                    [Reflection.Assembly]::LoadWithPartialName("System.EnterpriseServices") > $null
	
	                    # Create an instance of publish class
	                    [System.EnterpriseServices.Internal.Publish] $Publish = new-object System.EnterpriseServices.Internal.Publish
	
	                    # Add assembly to GAC
	                    $Publish.GacInstall($using:file)

                    }
                    TestScript = { Test-Path "$gacPath\$using:folderName" }
                    GetScript = { @{ Result = (Test-Path "$gacPath\$using:folderName") }}
                }
            }
        }
}
