param(
[Parameter(Mandatory=$false)][String]$policyAssignmentRG,
[Parameter(Mandatory=$true)][String]$policyDefRootFolder,
[Parameter(Mandatory=$false)][String]$subscriptionname
)
$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
if($policyAssignmentRG -ne $null)
{
$Subscription = Get-AzSubscription -SubscriptionName $subscriptionname
}
if($subscriptionname -ne $null)
{
$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)
}
foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected =  Get-AzPolicyDefinition -Name $policyDefFolder.Name
    Write-Host Creating assignment for: $selected
    write-host "select release environment '$($Release.EnvironmentName))'"
    if ($resourcegroupID -ne $null)
    {
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope $resourcegroupID -PolicyParameter  "$($policyDefFolder.FullName)\values.dev.json"
    }else
    {
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope "/subscriptions/$($Subscription.Id)" -PolicyParameter  "$($policyDefFolder.FullName)\values.dev.json"
    }
}
