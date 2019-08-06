Configuration BuildAgent
{
    Import-DscResource -Module cChoco
    Node 'localhost'
    {

        cChocoInstaller InstallChoco
        {
            InstallDir              = "c:\choco"
            ChocoInstallScriptUrl   = "http://<ip>:8081/repository/nuget/scripts/chocoInstall/0.0.1/chocoInstall-0.0.1.ps1" 
        }

        cChocoSource ExternalRepo
        {
            Name   = 'chocolatey'
            Ensure = 'Absent'
        }

        cChocoSource InternalRepo
        {
            Name   =  'nexus'
            Ensure = 'Present'
            Source = 'http://<ip>:8081/repository/choco-hosted/'
        }


        cChocoPackageInstallerSet installBasePackages
        {
            Ensure               = 'Present'
            Name                 = @(
                                    'git',
                                    'python2',
                                    'nodejs',
                                    'notepadplusplus'

                                    )
            DependsOn            = '[cChocoInstaller]installChoco'
        }
    }
}
