<#
    .NAME
        DtcConfig.ps1
    .SYNOPSIS
        Uses PowerShell DSC to configure DTC 
    .AUTHOR
        Dan Tracey
    .DATE
        28 / 05 /2019
    .VERSION
        0.1
    .CHANGELOG
        28 / 05 /2019 - 0.1 - Initial Script (DanT)
#>

Configuration 'DtcConfig'
    {

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName cDtc

        Node localhost
        {
            cDtcNetworkSetting ConfigureDtc
            {
                DtcName = "Local"
                RemoteClientAccessEnabled = $true
                RemoteAdministrationAccessEnabled = $true
                InboundTransactionsEnabled = $true
                OutboundTransactionsEnabled = $true
		            XATransactionsEnabled = $true
                AuthenticationLevel = "Mutual"
            }
        }
    }
