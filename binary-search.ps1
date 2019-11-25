# PowerShell Binary Search Algorithm - Dan Tracey

# Instantiate an array of numbers
$arr = @(1..1000)

# Shuffle the array
$arr = $arr | Sort-Object {Get-Random}

# Re-sort the array and check
$arr = $arr | Sort-Object
if (($arr | Select-Object -First 1) -gt ($arr | Select-Object -Last 1)){
    Write-Error "`$arr not sorted!"
}

# Prompt user for a number
$numberToFind = Read-Host "Enter the number you're looking for"

# Set up the search
$numberFound = $false
$tries = 0

# define search index
$lowIndex = 0
$highIndex = $arr.Count
$srchIndex = [Math]::Round(($highIndex - $lowIndex) / 2) + $lowIndex
Write-Host "`$lowIndex: $lowIndex || `$highIndex: $highIndex || `$srchIndex: $srchIndex"

while ($numberFound -eq $false) {

    $srchIndex = [Math]::Round(($highIndex - $lowIndex) / 2) + $lowIndex

    # number found!
    if ($srchIndex -eq $numberToFind){
        Write-Host "Found `$numberToFind ($numberToFind) at `$arr Index ($srchIndex)!"
        $numberFound = $true
    }
    else {
        $tries += 1
        Write-Warning "Number not found yet - `$srchIndex: $srchIndex - `$tries: $tries..."
    }
    
    if ($arr[$srchIndex] -gt $numberToFind){ # if the current searched number is GREATER than the target number, we need to adjust the search
        if($highIndex -eq $srchIndex){
            Write-Warning "Number not found yet - too high `$tries: $tries..."
            $tries += 1
        }
        else {
            $highIndex = $srchIndex
            #Write-Host "Going lower. Max is now $srchIndex"
        }
    }
    else {
        # if the current searched number is LOWER than the target number, we need to adjust the search
        if($lowIndex -eq $srchIndex){
            Write-Warning "Number not found yet - too low `$tries: $tries..."
            $tries += 1
        }
        else {
            $lowIndex = $srchIndex
            #write-host "Going higher. Max is now $srchIndex"
        }
    }
}
