@{

    Modules    =   @(
        @{
            Name        = 'xPSDesiredStateConfiguration'
            Version     = '8.6.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
        @{
            Name        = 'NetworkingDsc'
            Version     = '7.1.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
        @{
            Name        = 'xSystemSecurity'
            Version     = '1.4.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
        @{
            Name        = 'OctopusDSC'
            Version     = '2.0.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
        @{
            Name        = 'SqlServerDsc'
            Version     = '12.3.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
    )

    Binaries    =   @(

        @{
            Name        = 'dotnetfx3'
            Version     = '1.0'
            Type        = 'cab' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'microsoft-windows-netfx3-ondemand-package' 
        }
        @{
            Name        = 'ssms'
            Version     = '17.2'
            Type        = 'exe' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'SSMS-Setup-ENU' 
        }
        @{
            Name        = 'vcredist'
            Version     = '2015-x64'
            Type        = 'exe' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'vcredist'
        }
        @{
            Name        = 'sqlserver-express'
            Version     = '2017-x64'
            Type        = 'zip' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'sqlserver-express' 
        }
        @{
            Name        = 'google-chrome' 
            Version     = '73.0.3683.103' 
            Type        = 'msi' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'GoogleChromeStandaloneEnterprise64'
        }
    )
}
