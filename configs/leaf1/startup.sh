#!/bin/bash

# Create bridge
ip link add br10 type bridge
ip link set br10 up

# Create VXLAN interface
ip link add vxlan10010 type vxlan \
    id 10010 \
    dstport 4789 \
    local 2.2.2.1 \
    nolearning
ip link set vxlan10010 master br10
ip link set vxlan10010 up

# Create VLAN subinterface
ip link add link br10 name br10.10 type vlan id 10
ip link set br10.10 up

# Assign anycast gateway IP
ip addr add 192.168.10.254/24 dev br10.10

# Add client interface to bridge
ip link set eth10 master br10
ip link set eth10 up

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
