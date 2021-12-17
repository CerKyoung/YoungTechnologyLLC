<#
    .SYNOPSIS
        Export NSG rules from ALL NSGs in a given subscription. 
    
    .DESCRIPTION
        Export NSG rules from ALL NSGs in a given subscription.  Outputs all the security rule configuration into individual file outputs. This uses the Azure Az module.
        Commented out sections are for deleting and importing nsg rules from CSV. 
    
    .PARAMETER PlaceHolder
        PlaceHolder.
              
    .INPUTS
        Description of objects that can be piped to the script.

    .OUTPUTS
        Description of objects that are output by the script.
    
    .EXAMPLE
        Example of how to run the script.
    
    .LINK
        Links to further documentation.
    
    .NOTES  
        Author: Kevin Young
        Date: 12/16/2021
        Version: 2.0
    .NOTES
    May need to Connect Account, and be sure to set Context(line35), or may get all data you have perms too.
    ($exportpath and $SubID) Required Updates
#>
#  Connect-AzAccount
$SubID = '<SubscritptionID>'
$nsgs = Get-AzNetworkSecurityGroup
$exportPath = '<C:\somewhere>'
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