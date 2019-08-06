<#
    .NAME
        TomcatInstall.ps1
    .SYNOPSIS
        Uses PowerShell DSC to Install Apache Tomcat
    .AUTHOR
        Dan Tracey
    .DATE
        29 / 04 /2019
    .VERSION
        0.2
    .CHANGELOG
        11 / 04 /2019 - 0.1 - Initial Script (DanT)
        29 / 04 /2019 - 0.1 - Added logic for installing as a service and configuring (DanT)
#>

Configuration 'TomcatInstall'
    {
        Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$tcCreds,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]$BuildCreds

        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xPSDesiredStateConfiguration
        Import-DscResource -ModuleName xSmbShare
        
        $tcusername = $tcCreds.Username
        $tcpassword = $tcCreds.GetNetworkCredential().password

        $contents =  @"
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

<role rolename="manager"/> 
<role rolename="admin"/> 
<role rolename="admin-gui"/> 
<role rolename="admin-script"/> 
<role rolename="manager-gui"/> 
<role rolename="manager-script"/> 
<role rolename="manager-jmx"/> 
<role rolename="manager-status"/> 
<user username="$tcusername" password="$tcpassword" roles="admin,manager,manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>
<user username="$tcusername" password="$tcpassword" roles="admin,manager,manager-gui,manager-script,manager-jmx,manager-status"/>

</tomcat-users>
"@

        Node localhost
        {
           
            xGroupSet AddUserToLocalAdminsGroup
            {
                GroupName            = "Administrators"
                MembersToInclude     = $tcCreds.Username
                Credential           = $BuildCreds
            }
            
            Archive InstallTomcat
            {
                Destination     = "C:\"
                Path            = $Node.TomcatInstallFiles
                Ensure          = "Present"
            }

            File CopySqlFile
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\lib\sqljdbc4-1.0.jar"
                SourcePath      = $Node.SqlJdbcJarFile
                Ensure          = "Present"
            }
            
            File CreateAppConfigFolder
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\app-config"
                Type            = "Directory"
                Ensure          = "Present"
                DependsOn       = "[Archive]InstallTomcat"
            }

            xSmbShare ShareAppConfigFolder
            {
                Ensure          = 'Present'
                Name            = 'app-config'
                Path            = "C:\apache-tomcat-9.0.6\app-config"
                FullAccess      = 'Everyone'
                DependsOn       = "[File]CreateAppConfigFolder"

            }

            File CreateDasWebFolder
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\app-config\das-web"
                Type            = "Directory"
                Ensure          = "Present"
                DependsOn       = "[File]CreateAppConfigFolder"
            }

            File CreateDasWebServicesFolder
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\app-config\das-webservices"
                Type            = "Directory"
                Ensure          = "Present"
                DependsOn       = "[File]CreateAppConfigFolder"
            }

            File CreateTomcatUsersFile
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\conf\tomcat-users.xml"
                Type            = "File"
                Ensure          = "Present"
                Contents        = $contents
                Force           = $true
                DependsOn       = "[Archive]InstallTomcat"
            }

            File RemoveExamplesFolder
            {
                DestinationPath = "C:\apache-tomcat-9.0.6\webapps\examples"
                Type            = "Directory"
                Ensure          = "Absent"
                Contents        = $contents
                Force           = $true
                DependsOn       = "[Archive]InstallTomcat"
            } 

            $jvmArgs = '//IS//Tomcat9 --Jvm="C:\Program Files\Java\jdk1.8.0_161\jre\bin\server\jvm.dll" --Classpath="C:\apache-tomcat-9.0.6\bin\bootstrap.jar;C:\apache-tomcat-9.0.6\bin\tomcat-juli.jar" --JvmMs=756 --JvmMx=1024'
            $serviceArgs = ' --DisplayName="Apache Tomcat 9.0 Tomcat9" --Description="Apache Tomcat 9.0.6 Server - http://tomcat.apache.org/" --Startup=auto'
            $tcArgs = ' --Install="C:\apache-tomcat-9.0.6\bin\tomcat9.exe"'
            $startArgs = ' --StartMode=jvm --StartClass=org.apache.catalina.startup.Bootstrap --StartParams=start'
            $stopArgs  = ' --StopMode=jvm --StopClass=org.apache.catalina.startup.Bootstrap --StopParams=stop'
            $jvmOptions = ' --JvmOptions=-Dcatalina.base=C:\apache-tomcat-9.0.6#-Dcatalina.home=C:\apache-tomcat-9.0.6#-Dignore.endorsed.dirs=C:\apache-tomcat-9.0.6\endorsed#-Djava.io.tmpdir=C:\apache-tomcat-9.0.6\temp#-Dcom.sun.management.jmxremote.port=8086#-Dcom.sun.management.jmxremote.ssl=false#-Dcom.sun.management.jmxremote.authenticate=false#-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager#-Djava.util.logging.config.file=C:\apache-tomcat-9.0.6\conf\logging.properties#-Djavax.servlet.request.encoding=UTF-8#-Dfile.encoding=UTF-8#-Duser.timezone=UTC' 
            $jvmOptions9 = ' --JvmOptions9=--add-opens=java.base/java.lang=ALL-UNNAMED#--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED'
            $logOptions = ' --LogPath="C:\apache-tomcat-9.0.6\logs" --LogLevel=Info --StdOutput=Auto --StdError=Auto'

            Script InstallTomcatService
            {
                SetScript = {

                    Start-Process -FilePath '.\tomcat9.exe' -WorkingDirectory 'C:\apache-tomcat-9.0.6\bin' -ArgumentList "$using:jvmArgs$using:serviceArgs$using:tcArgs$using:startArgs$using:stopArgs$using:jvmOptions$using:jvmOptions9$using:logOptions" -Wait -PassThru
                    start-process -FilePath 'sc.exe' -ArgumentList "failure tomcat9  actions= restart/60000/restart/60000/restart/60000 reset= 60" -Wait -PassThru
                    
                }
                TestScript = { 
                    if( Get-WmiObject win32_service -Filter "name like 'Tomcat9'"  )
                        {
                            return $true
                        }
                    return $false
                    }
                GetScript = { @{ 
                    Result = (Get-WmiObject win32_service -Filter "name like 'Tomcat9'") }
                    }
                DependsOn       = "[Archive]InstallTomcat"
            }
            
            xService TomcatAccount
            {
                Name           = 'Tomcat9'
                Credential     = $tcCreds
                StartupType    = "Automatic"
                State          = "Running"
                StartupTimeout = 30
                DependsOn      = "[Script]InstallTomcatService"
            }
         }
    }
