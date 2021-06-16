Param(
[String]$policyDefRootFolder,
[String]$subscriptionName,
[String]$ManagementGroupName 
)
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
        $policy.PolicyRulePath = $($policyDefinition.FullName  + "\policydef.json")
        write-host "check policy rule path '$($policy.PolicyRulePath)'"
        $policy.PolicyParamPath = $($policyDefinition.FullName + "\policydef.params.json")
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
        if($null -ne $subscriptionId)
        {
        $policyDef = New-AzPolicyDefinition -Name $policy.PolicyName -Policy $policy.PolicyRulePath -Parameter $policy.PolicyParamPath -SubscriptionId $subscriptionId -Metadata '{"category":"Pipeline"}'
        }
        else{
         $policyDef = New-AzPolicyDefinition -Name $policy.PolicyName -Policy $policy.PolicyRulePath -Parameter $policy.PolicyParamPath -ManagementGroupName $ManagementGroupName -Metadata '{"category":"Pipeline"}'   
        }
        $policyDefList += $policyDef
    }
    return $policyDefList
}
if($null -ne $subscriptionName)
{
$subscriptionId = (Get-AzSubscription -SubscriptionName $subscriptionName).Id
}
Write-Verbose $policyDefRootFolder
Write-Verbose $subscriptionId

#get list of policy folders
$policies = Select-Policies -PolicyFolders (Get-ChildItem -Path $policyDefRootFolder -Directory)
write-host $policies
$policyDefinitions = Add-Policies -Policies $policies -subscriptionId $subscriptionId
$policyDefsJson = ($policyDefinitions | ConvertTo-Json -Depth 10 -Compress)

Write-Host "##vso[task.setvariable variable=PolicyDefs]$policyDefsJson"
