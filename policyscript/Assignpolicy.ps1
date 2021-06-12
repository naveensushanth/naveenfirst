$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
$policyAssignmentRG = "test"
$policyDefRootFolder = "_test-CI/drop"

$resourcegroupID = ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId)

foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected =  Get-AzPolicyDefinition -Name $policyDefFolder.Name
    Write-Host Creating assignment for: $selected
    write-host "select release environment '$($Release.EnvironmentName))'"
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope $resourcegroupID -PolicyParameter  "$($policyDefFolder.FullName)\values.dev.json"

}
