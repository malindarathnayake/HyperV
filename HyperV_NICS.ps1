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

Add-VMNetworkAdapter –ManagementOS –Name "Live_Migration_NET" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Live_Migration_NET" -Access -VlanId 22
Set-VMNetworkAdapter -ManagementOS -Name "Live_Migration_NET" -VmqWeight 80 -MinimumBandwidthWeight 10

Add-VMNetworkAdapter –ManagementOS –Name "Cluster_NET" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Cluster_NET" -Access -VlanId 22
Set-VMNetworkAdapter -ManagementOS -Name "Cluster_NET" -VmqWeight 80 -MinimumBandwidthWeight 10

# ISCSI NICs

Add-VMNetworkAdapter –ManagementOS –Name "ISCSI01" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "ISCSI01" -Access -VlanId 15
Set-VMNetworkAdapter -ManagementOS -Name "ISCSI01" -VmqWeight 100 -MinimumBandwidthWeight 40
  
Add-VMNetworkAdapter –ManagementOS –Name "ISCSI02" –SwitchName "DVSwitch01"  
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "ISCSI02" -Access -VlanId 15
Set-VMNetworkAdapter -ManagementOS -Name "ISCSI02" -VmqWeight 100 -MinimumBandwidthWeight 40
