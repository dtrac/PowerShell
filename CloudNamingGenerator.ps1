<#
    The Cloud naming convention is outlined below

    XXYYYZ-00000123

    Where

    XX = Cloud prefix - GC for GCP, AZ for Azure, AW for AWS

    YYY = Region Code i.e EW1 for Europe West 1

    Z = Availability Zone i.e. Zone A

    8 digits number which automatically increments.

    E.g: GCEW1A-12345678 (GCP Europe West 1 Zone A)
#>

$cloudPrefix = 'GC'
$regionCode = 'EW1'
$availabilityZone = 'A'
$servernameList = '.\servernameList.csv'

function New-ServernamePrefix {
    Param (
        [ValidateLength(2,2)]
        [ValidateSet("AW","AZ","GC")]
        [string]$CloudPrefix,

        [ValidateLength(3,3)]
        [string]$RegionCode,

        [ValidateLength(1,1)] 
        [string]$AvailabilityZone
    )

    $serverNameprefix = $cloudPrefix + $regionCode + $availabilityZone + '-'
    
    return $serverNameprefix
}

function CreateServerList ($ServernameList,$ServernamePrefix) {

[System.Collections.ArrayList]$parentArr = @()
1..999 | foreach { # Change to 99999999
        $childObj = New-Object -TypeName psobject
        $childObj | Add-Member -MemberType NoteProperty -Name name -Value $($Servernameprefix + $_.ToString("00000000"))
        $childObj | Add-Member -MemberType NoteProperty -Name inuse -Value 'False'
        $parentArr.Add($childObj) | Out-Null
    }
    $parentArr | Export-Csv -NoTypeInformation $servernameList
}

function Reserve-Servername ($ServernameList) {
    
    $serverList = Import-Csv $ServernameList
    $unusednames = $serverList.where({$_.inuse -ne "True"})
    $selectedname = ($unusednames | Select -First 1).name

    $Output = foreach ($row in $serverList){
        #Write-Host $row.name
        if ($row.name -like $selectedname){
           $row.inuse = "True"
        }
        $row
    }
    $Output | Export-Csv $ServernameList

    return $selectedname
}

# generate a prefix
$Servernameprefix = New-ServernamePrefix -CloudPrefix $cloudPrefix -RegionCode $regionCode -AvailabilityZone $availabilityZone

# create the initial server list
CreateServerList -ServernameList $servernameList -Servernameprefix $ServernamePrefix

# generate a new server name
Reserve-Servername -ServernameList $servernameList
