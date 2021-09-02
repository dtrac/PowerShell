$subs = Get-AzSubscription

 

foreach($entry in $subs)

{

   Write-Output "`nSubscription Name $($entry.Name)"

   Write-Output "`nSubscription ID $($entry.Id)"

 

   # get current tags:

   $tags = Get-AzTag -ResourceId /subscriptions/$($entry.Id)

   $newtag = @{"Key"="Value"}

   Update-AzTag -ResourceId /subscriptions/$($entry.Id) -Tag $newtag -Operation Merge

 

}
