param(
[Parameter(Mandatory=$false)][String]$policyAssignmentRG,
[Parameter(Mandatory=$true)][String]$policyDefRootFolder,
[Parameter(Mandatory=$false)][String]$subscriptionname
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
$policyresourcegroup = $policyAssignmentRG
$policysubscriptionname = $subscriptionname
write-host "'$($policyresourcegroup)' and '$($policysubscriptionname)'"
write-host [bool]$policyresourcegroup and $policyresourcegroup.count
write-host [bool]$policysubscriptionname and $policysubscriptionname.count
if($policyAssignmentRG.count -ne 0)
{
Write-host "'$($policyAssignmentRG)'"
write-host resource group $policyAssignmentRG.count
$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)
}
if($subscriptionname.count -ne 0)
{
Write-host "'$($subscriptionname)'"
write-host subscription name: $subscriptionname.count
$Subscription = Get-AzSubscription -SubscriptionName $subscriptionname

}
foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected =  Get-AzPolicyDefinition -Name $policyDefFolder.Name
    Write-Host Creating assignment for: $selected
    write-host "select release environment '$($Release.EnvironmentName))'"
    if ($resourcegroupID -ne $null)
    {
    Write-host "inside forloop '$($policyAssignmentRG)'"
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope $resourcegroupID -PolicyParameter  "$($policyDefFolder.FullName)\values.dev.json"
    }
    if($Subscription -ne $null)
    {
    Write-host "inside for loop1 '$($subscriptionname)'"
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope "/subscriptions/$($Subscription.Id)" -PolicyParameter  "$($policyDefFolder.FullName)\values.dev.json"
    }
}
