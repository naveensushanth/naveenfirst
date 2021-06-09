write-host "all variable set successfully"
$policyDefRootFolder = '_test-CI/drop'
$subscriptionName = "Pay-As-You-Go"
write-host "all variable set successfully $($policyDefRootFolder)"
class PolicyDef {
    [string]$PolicyName
    [string]$PolicyRulePath
    [string]$PolicyParamPath
    [string]$ResourceId
}

function Select-Policies {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$PolicyFolders
    )

    Write-Verbose "Processing policies"
    $policyList = @()
    foreach ($policyDefinition in $PolicyFolders) {
        $policy = New-Object -TypeName PolicyDef
        $policy.PolicyName = $policyDefinition.Name
        write-host "all variable set successfully $($policyDefinition.Name)"
        $policy.PolicyRulePath = '$($policyDefinition.FullName  + "\policydef.json")'
        $policy.PolicyParamPath = '$($policyDefinition.FullName  + "\policydef.params.json")'
        write-host "all variable set successfully $($policyDefinition.FullName)"
        $policyList += $policy
    }

    return $policyList
}

function Add-Policies {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [PolicyDef[]]$Policies,
        [String]$subscriptionId
    )

    Write-Verbose "Creating policy definitions"
    $policyDefList = @()
    foreach ($policy in $Policies) {
    write-host "all variable set successfully $($policy.PolicyRulePath)"
        $policyDef = New-AzPolicyDefinition -Name $policy.PolicyName -Policy $policy.PolicyRulePath -Parameter $policy.PolicyParamPath -SubscriptionId $subscriptionId -Metadata '{"category":"Pipeline"}'
        $policyDefList += $policyDef
    }
    return $policyDefList
}

$subscriptionId = (Get-AzSubscription -SubscriptionName $subscriptionName).Id
Write-Verbose $policyDefRootFolder
Write-Verbose $subscriptionId

#get list of policy folders
$policies = Select-Policies -PolicyFolders (Get-ChildItem -Path $policyDefRootFolder -Directory)
$policyDefinitions = Add-Policies -Policies $policies -subscriptionId $subscriptionId
$policyDefsJson = ($policyDefinitions | ConvertTo-Json -Depth 10 -Compress)

Write-Host "##vso[task.setvariable variable=PolicyDefs]$policyDefsJson"
