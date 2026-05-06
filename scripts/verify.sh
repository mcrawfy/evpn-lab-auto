#!/bin/bash

echo "========================================="
echo "EVPN/VXLAN Fabric Verification - evpn-lab-auto"
echo "========================================="
echo ""

echo "--- OSPF Neighbors (Spine1) ---"
sudo docker exec clab-evpn-lab-auto-spine1 vtysh -c "show ip ospf neighbor" 2>/dev/null | grep -E "Full|State"
echo ""

echo "--- BGP EVPN Summary (Spine1) ---"
sudo docker exec clab-evpn-lab-auto-spine1 vtysh -c "show bgp l2vpn evpn summary" 2>/dev/null | tail -8
echo ""

echo "--- VXLAN Interface (Leaf1) ---"
sudo docker exec clab-evpn-lab-auto-leaf1 ip link show vxlan10010 2>/dev/null | head -2
echo ""

echo "--- L2 Connectivity Test (Client1 -> Client2) ---"
sudo docker exec clab-evpn-lab-auto-client1 ping -c 3 192.168.10.12 2>/dev/null | tail -4
echo ""

echo "========================================="
echo "Verification Complete"
echo "========================================="
