@{

    Modules    =   @(
        @{
            Name        = 'OctopusDSC'
            Version     = '2.0.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
        @{
            Name        = 'xPSDesiredStateConfiguration'
            Version     = '8.6.0.0'
            Type        = 'zip' 
            Group       = 'dsc'
        }
    )

    Binaries    =   @(

        @{
            Name        = 'octo' 
            Version     = '2.5.10.39'
            Type        = 'zip' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'Octo' 
        }
        @{
            Name        = 'octopus-tentacle' 
            Version     = '3.15.8-x64'
            Type        = 'msi' 
            Group       = 'packages'
            TargetDir   = 'C:\Windows\Temp'
            TargetName  = 'Octopus.Tentacle.3.15.8-x64' 
        }
    )
}
