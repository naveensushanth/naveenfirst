Param(
[String]$policyDefRootFolder,
[Parameter(Mandatory = $false)][String]$Subscriptionname,
[Parameter(Mandatory = $false)][String]$policyAssignmentRG = ''
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
write-host "set parameters '$($policyDefRootFolder)' & '$($env:POLICYDEFS)'"
write-host "set parameters '$($policyAssignmentRG)'"

if($null -eq $policyAssignmentRG ){
write-host "This assignment is for Subscription level"

}else
{
$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)
}

if($null -eq $Subscriptionname){
write-host "This assignment is for Resource group level"

}
else
{
$SubscriptionId = ((Get-AzSubscription -SubscriptionName $Subscriptionname).Id)
}

foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected = $policyObjs | Where-Object { $_.Name -eq $policyDefFolder.Name }
    
    Write-Host "Creating assignment for: '$($selected)'"
   if($null -ne $resourcegroupID)
   {
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope $resourcegroupID -PolicyParameter  "$($policyDefFolder.FullName)\values.$(Release.EnvironmentName).json"

   }
   else{
     New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope "/subscriptions/$SubscriptionId"  
   
   }
   
}
