Param(
[String]$policyDefRootFolder,
[Parameter(Mandatory = $false)][String]$Subscriptionname,
[Parameter(Mandatory = $false)][String]$policyAssignmentRG = $null
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
write-host "set parameters '$($policyDefRootFolder)' & '$($env:POLICYDEFS)'"
write-host "set parameters '$($policyAssignmentRG)'"

if($null -ne $Subscriptionname){
$SubscriptionId = ((Get-AzSubscription -SubscriptionName $Subscriptionname).Id)
}


foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected = $policyObjs | Where-Object { $_.Name -eq $policyDefFolder.Name }
    
    Write-Host "Creating assignment for: '$($selected)'"
   if($null -ne $policyAssignmentRG)
   {
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId) -PolicyParameter  "$($policyDefFolder.FullName)\values.$(Release.EnvironmentName).json"

   }
   else{
     New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope "/subscriptions/$SubscriptionId"  
   
   }
   
}