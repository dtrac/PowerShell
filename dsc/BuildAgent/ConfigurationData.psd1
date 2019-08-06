@{

    Modules    =   @(
        @{Name = 'cChoco' ;
            Versions = @('2.4.0.0')}
    
    )

    Apps       =   @(

        @{Name = 'dotnetfx' ; 
            Versions = @('4.5.0.0','4.5.1.0','4.5.2.0','4.6.0.0','4.6.1.0','4.6.2.0','4.7.2.20180712')}

        @{Name = 'dotnetcore-sdk' ; 
            Versions = @('2.0.0','2.0.0.20170906','2.1.201','2.1.202','2.1.300','2.1.301','2.1.400','2.1.500','2.1.505')}

        @{Name = 'dotnetcore-runtime' ; 
            Versions = @('2.1.0','2.1.1')}

        @{Name = 'aspnetcore-runtimepackagestore' ; 
            Versions = @('2.1.0','2.1.1')}
        
        @{Name = 'dotnetcore-windowshosting' ; 
            Versions = @('2.0.0','2.1.0','2.1.1') ;
                Params = 'IgnoreMissingIIS'}

        @{Name = 'microsoft-build-tools' ; 
            Versions = @('14.0.25420.1')}

        @{Name = 'vs-buildtools' ; 
            Versions = @('15.9.11')}
        
    )
}
