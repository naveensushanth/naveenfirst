Param(
[String]$policyDefRootFolder,
[Parameter(Mandatory = $false)][String]$Subscriptionname,
[Parameter(Mandatory = $false)][String]$policyAssignmentRG = $null
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
write-host "set parameters '$($policyDefRootFolder)' & '$($env:POLICYDEFS)'"
write-host "set parameters '$($policyAssignmentRG)'"
if($policyAssignmentRG -ne $null){
write-host "wrong loop"
$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)
}

if($null -ne $Subscriptionname){
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
