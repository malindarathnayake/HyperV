#
$10GBNICS = Get-NetAdapter | Where-Object {$_.LinkSpeed -gt "1"}
$Noofnics = $10GBNICS.name.count
$a,$b,$c,$d = $10GBNICS.name.split('')
#
New-NetLbfoTeam -Name "DVSWTEAM01" -TeamMembers "$a","$b","$C","$d"
Set-NetLbfoTeam -Name "DVSWTEAM01" -TeamingMode LACP -LoadBalancingAlgorithm Dynamic 
#
#
# Create a Hyper-V virtual switch connected to the network team  
# Enable QoS in Weight mode  
New-VMSwitch "DVSwitch01" –NetAdapterName "DVSWTEAM01" –MinimumBandwidthMode Weight –AllowManagementOS $false  
  
# Configure the default bandwidth weight for the switch  
# Ensures all virtual NICs have a weight  
Set-VMSwitch -Name "DVSwitch01" -DefaultFlowMinimumBandwidthWeight 0  
  
# Create virtual network adapters on the management operating system  
# Connect the adapters to the virtual switch  
# Set the VLAN associated with the adapter  
# Configure the VMQ weight and minimum bandwidth weight 

#Management VNIC

Add-VMNetworkAdapter –ManagementOS –Name "Management" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Management" -Access -VlanId 254 
Set-VMNetworkAdapter -ManagementOS -Name "Management" -VmqWeight 80 -MinimumBandwidthWeight 10

Add-VMNetworkAdapter –ManagementOS –Name "Cluster_NET" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Cluster_NET" -Access -VlanId 6
Set-VMNetworkAdapter -ManagementOS -Name "Cluster_NET" -VmqWeight 80 -MinimumBandwidthWeight 10

Add-VMNetworkAdapter –ManagementOS –Name "Live_Migration_NET" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Live_Migration_NET" -Access -VlanId 7
Set-VMNetworkAdapter -ManagementOS -Name "Live_Migration_NET" -VmqWeight 80 -MinimumBandwidthWeight 10
# ISCSI NICs
Add-VMNetworkAdapter –ManagementOS –Name "ISCSI_FaultDomain01_NIC01" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "ISCSI_FaultDomain01_NIC01" -Access -VlanId 800
Set-VMNetworkAdapter -ManagementOS -Name "ISCSI_FaultDomain01_NIC01" -VmqWeight 100 -MinimumBandwidthWeight 40
#
Add-VMNetworkAdapter –ManagementOS –Name "ISCSI_FaultDomain01_NIC02" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "ISCSI_FaultDomain01_NIC02" -Access -VlanId 800
Set-VMNetworkAdapter -ManagementOS -Name "ISCSI_FaultDomain01_NIC02" -VmqWeight 100 -MinimumBandwidthWeight 40
#
#
New-NetIPAddress -InterfaceAlias "vEthernet (Management)" -IPAddress 172.17.254.50 -PrefixLength 24 -DefaultGateway 172.17.254.254 -Type Unicast
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Management)" -ServerAddresses ("192.168.1.51","192.168.1.62")
#
New-NetIPAddress -InterfaceAlias "vEthernet (Cluster_NET)" -IPAddress 172.17.6.50 -PrefixLength 24 -DefaultGateway 172.17.6.254 -Type Unicast
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Cluster_NET)" -ServerAddresses ("192.168.1.51","192.168.1.62")
#
New-NetIPAddress -InterfaceAlias "vEthernet (Live_Migration_NET)" -IPAddress 172.17.7.50 -PrefixLength 24 -Type Unicast
#
New-NetIPAddress -InterfaceAlias "vEthernet (ISCSI_FaultDomain01_NIC02)" -IPAddress 10.50.37.50 -PrefixLength 24 -Type Unicast
New-NetIPAddress -InterfaceAlias "vEthernet (ISCSI_FaultDomain01_NIC01)" -IPAddress 10.50.37.50 -PrefixLength 24 -Type Unicast