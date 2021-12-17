<#
This is pretty easy
This searches for all NSGs in a given subscription
Outputs all the security rule configuration into individual file outputs
This uses the Azure Az module
#>
#  Connect-AzAccount
$SubID = '<SubscritptionID>'
$nsgs = Get-AzNetworkSecurityGroup
$exportPath = 'C:\Users\P12060D\OneDrive - Ceridian HCM Inc\Azure\scripts\Exports'
Set-AzContext -Subscription $SubID
Foreach ($nsg in $nsgs){
New-Item -ItemType file -Path "$exportPath\$($nsg.Name).csv" -Force
$nsgRules = $nsg.SecurityRules
    foreach ($nsgRule in $nsgRules){
    $nsgRule | Select-Object Name,Description,Priority,Protocol,Access,Direction,@{Name=’SourceAddressPrefix’;Expression={[string]::join(“,”, ($_.SourceAddressPrefix))}},@{Name=’SourcePortRange’;Expression={[string]::join(“,”, ($_.SourcePortRange))}},@{Name=’DestinationAddressPrefix’;Expression={[string]::join(“,”, ($_.DestinationAddressPrefix))}},@{Name=’DestinationPortRange’;Expression={[string]::join(“,”, ($_.DestinationPortRange))}} `
    | Export-Csv "$exportPath\$($nsg.Name).csv" -NoTypeInformation -Encoding ASCII -Append}
}


<# Script 2 - Delete NSG security configuration rules via a CSV
$NSG = Get-AzNetworkSecurityGroup -Name <NetworkSecurityGroup> -ResourceGroupName <ResourceGroup>
foreach($rule in import-csv "<C:\CSVFILEHERE.csv>"){$NSG | Remove-AzNetworkSecurityRuleConfig -Name $rule.name}
$NSG | Set-AzNetworkSecurityGroup
#>
<# Script 3 - Sound the alarm! Mayday! Put it all back
$NSG = Get-AzNetworkSecurityGroup -Name <NetworkSecurityGroup> -ResourceGroupName <ResourceGroup>
foreach($rule in import-csv "<C:\CSVFILEHERE.csv>"){
$NSG | Add-AzNetworkSecurityRuleConfig `
-Name $rule.name `
-Description $rule.Description `
-Priority $rule.Priority `
-Protocol $rule.Protocol `
-Access $rule.Access `
-Direction $rule.Direction `
-SourceAddressPrefix ($rule.SourceAddressPrefix -split ',') `
-SourcePortRange ($rule.SourcePortRange -split ',') `
-DestinationAddressPrefix ($rule.DestinationAddressPrefix -split ',') `
-DestinationPortRange ($rule.DestinationPortRange -split ',')
}
$NSG | Set-AzNetworkSecurityGroup
#>