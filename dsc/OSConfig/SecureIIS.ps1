<#
    .NAME
        SecureIIS.ps1
    .SYNOPSIS
        Uses PowerShell DSC to secure IIS
    .AUTHOR
        Dan Tracey
    .DATE
        29 / 04 /2019
    .VERSION
        0.1
    .CHANGELOG
        29 / 04 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'SecureIIS' 
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node localhost
    {
        xRegistry DisableMultiProtocolUnifiedHello
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\Server'
            ValueName = 'Enabled'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry DisablePCT1_0
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server'
            ValueName = 'Enabled'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }
        
        xRegistry DisableSSL2_0
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server'
            ValueName = 'Enabled'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry DisableSSL3_0
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server'
            ValueName = 'Enabled'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry AddTLS1_0
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry EnableTLS1_0
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server'
            ValueName = 'DisabledByDefault'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry AddTLS1_1Server
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry EnableTLS1_1Server
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server'
            ValueName = 'DisabledByDefault'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry AddTLS1_1Client
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry EnableTLS1_1Client
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client'
            ValueName = 'DisabledByDefault'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry AddTLS1_2Server
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry EnableTLS1_2Server
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
            ValueName = 'DisabledByDefault'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry AddTLS1_2Client
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry EnableTLS1_2Client
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
            ValueName = 'DisabledByDefault'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }
        
        $insecureCiphers = @(
                              'DES 56/56',
                              'NULL',
                              'RC2 128/128',
                              'RC2 40/128',
                              'RC2 56/128',
                              'RC4 40/128',
                              'RC4 56/128',
                              'RC4 64/128',
                              'RC4 128/128'
                            )
        
        Foreach ($insecureCipher in $insecureCiphers) {
            
            xRegistry $insecureCipher
            {
                Ensure    = 'Present'
                Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$insecureCipher"
                ValueName = 'Enabled'
                ValueData = '0'
                ValueType = 'Dword'
                Force     = $True
            }
            
        }

        $secureCiphers = @(
                              'AES 128/128',
                              'AES 256/256',
                              'Triple DES 168/168'
                            )
        
        Foreach ($secureCipher in $secureCiphers) {
            
            xRegistry $secureCipher
            {
                Ensure    = 'Present'
                Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$secureCipher"
                ValueName = 'Enabled'
                ValueData = '1'
                ValueType = 'Dword'
                Force     = $True
            }
        }

        xRegistry SetMd5Hash
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5'
            ValueName = 'Enabled'
            ValueData = '0'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry SetShaHash
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\SHA'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry SetDiffieHellmanAlgorithm
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        xRegistry SetPKCSAlgorithm
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS'
            ValueName = 'Enabled'
            ValueData = '1'
            ValueType = 'Dword'
            Force     = $True
        }

        $cipherSuitesOrder = @(
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P521',
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384',
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256',
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P521',
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384',
                                'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P521',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P521',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P384',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P384',
                                'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P256',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P256',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P521',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P384',
                                'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P256',
                                'TLS_DHE_DSS_WITH_AES_256_CBC_SHA256',
                                'TLS_DHE_DSS_WITH_AES_256_CBC_SHA',
                                'TLS_DHE_DSS_WITH_AES_128_CBC_SHA256',
                                'TLS_DHE_DSS_WITH_AES_128_CBC_SHA',
                                'TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA',
                                'TLS_RSA_WITH_AES_256_CBC_SHA256',
                                'TLS_RSA_WITH_AES_256_CBC_SHA',
                                'TLS_RSA_WITH_AES_128_CBC_SHA256',
                                'TLS_RSA_WITH_AES_128_CBC_SHA',
                                'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
                            )
        $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)

        xRegistry SetCipherSuitesOrder
        {
            Ensure    = 'Present'
            Key       = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
            ValueName = 'Functions'
            ValueData = $cipherSuitesAsString
            ValueType = 'String'
            Force     = $True
        }
    }
}
