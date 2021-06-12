$policyObjs = ConvertFrom-Json -InputObject $env:POLICYDEFS
$policyAssignmentRG = "test"
$policyDefRootFolder = "_test-CI/drop"

foreach ($policyDefFolder in (Get-ChildItem -Path $policyDefRootFolder -Directory)) {

    Write-Host Processing folder: $policyDefFolder.Name
    $selected = $policyObjs | Where-Object { $_.Name -eq $policyDefFolder.Name }
    Write-Host Creating assignment for: $selected
    write-host "select release environment '$($Release.EnvironmentName))'"
    New-AzPolicyAssignment -Name $policyDefFolder.Name -PolicyDefinition $selected -Scope ((Get-AzResourceGroup -Name $policyAssignmentRG).ResourceId) -PolicyParameter  "$($policyDefFolder.FullName)\values.$(Release.EnvironmentName).json"

}
