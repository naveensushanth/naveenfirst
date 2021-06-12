param(
[Parameter(Mandatory=$false)][String]$policyAssignmentRG,
[Parameter(Mandatory=$true)][String]$policyDefRootFolder,
[Parameter(Mandatory=$false)][String]$subscriptionname
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
if($policyAssignmentRG.count -ne 0)
{
Write-host "'$($policyAssignmentRG)'"
$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)
}
if($subscriptionname.count -ne 0)
{
Write-host "'$($subscriptionname)'"
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
