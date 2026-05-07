# 🏗️ Automated EVPN/VXLAN Fabric with Ansible + Containerlab

[![Containerlab](https://img.shields.io/badge/Containerlab-0.74.3-blue)](https://containerlab.dev/)
[![Ansible](https://img.shields.io/badge/Ansible-8.7-red)](https://www.ansible.com/)
[![FRRouting](https://img.shields.io/badge/FRRouting-10.1.1-purple)](https://frrouting.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

## 🎯 What This Project Does

This repository automates the deployment of a **production-validated EVPN/VXLAN fabric** using Ansible and Containerlab. With a single command (`make deploy`), you get:

| Component | Technology | Details |
|-----------|------------|---------|
| **Physical Topology** | Clos (Spine-Leaf) | 2 spines, 3 leaves, 3 clients |
| **Underlay** | OSPF Point-to-Point | Fast convergence, no DR/BDR |
| **Overlay Control** | MP-BGP EVPN | Route Type 2 (MAC/IP), Route Reflectors |
| **Overlay Data** | VXLAN | VNI 10010, source interface Loopback0 |
| **L3 Gateway** | Anycast Gateway | 192.168.10.254/24 on all leaves |

**Manual time:** 45 minutes → **Automated time:** `make deploy` (30 seconds)

---

## 📊 Topology
┌─────────┐ ┌─────────┐
│ Spine1 │ │ Spine2 │
│ (FRR) │ │ (FRR) │
│AS 65000 │ │AS 65000 │
│1.1.1.1 │ │1.1.1.2 │
└────┬────┘ └────┬────┘
│ │
┌──────────┼───────────────┼──────────┐
│ │ │ │
┌────┴────┐ ┌───┴────┐ ┌────────┴───┐ │
│ Leaf1 │ │ Leaf2 │ │ Leaf3 │ │
│ (FRR) │ │ (FRR) │ │ (FRR) │ │
│AS 65001 │ │AS 65002│ │AS 65003 │ │
│2.2.2.1 │ │2.2.2.2 │ │2.2.2.3 │ │
└────┬────┘ └───┬────┘ └─────┬──────┘ │
│ │ │ │
┌────┴────┐ ┌───┴────┐ ┌──────┴───┐ │
│Client1 │ │Client2 │ │Client3 │ │
│.10.11/24│ │.10.12/24│ │.10.13/24│ │
└─────────┘ └────────┘ └──────────┘ │
│
VLAN 10 (VNI 10010) Stretched Across All Leaves
Anycast Gateway: 192.168.10.254 (same IP + MAC on all leaves)
---

## 🚀 Quick Start

### Prerequisites

| Requirement | Version | Installation |
|-------------|---------|--------------|
| **Ubuntu** | 22.04 / 24.04 | - |
| **Docker** | 24.0+ | `curl -fsSL https://get.docker.com \| sudo sh` |
| **Containerlab** | 0.74.0+ | `bash -c "$(curl -sL https://get.containerlab.dev)"` |
| **Ansible** | 8.0+ | `sudo apt install ansible -y` |
| **Python** | 3.10+ | Installed by default on Ubuntu 22.04+ |

### Deploy the Lab

```bash
# Clone the repository
git clone https://github.com/mcrawfy/evpn-lab-auto.git
cd evpn-lab-auto

# Deploy (generates configs + starts containers)
make deploy

# Verify everything is working
make verify

# When done, destroy the lab
make destroy
🎮 Makefile Commands
Command	What It Does
make generate	Generate FRR configs from Ansible templates
make deploy	Generate + deploy lab + wait for convergence
make verify	Validate OSPF, BGP EVPN, VXLAN, L2 connectivity
make destroy	Stop and remove all containers
make clean	Destroy + remove generated configs
make reload	Full clean + redeploy
📁 Repository Structure
evpn-lab-auto/
├── Makefile                    # One-command automation
├── .gitignore                  # Prevents committing runtime files
├── automation/                 # Source of truth
│   ├── inventory/
│   │   └── lab.yml            # Node variables (AS numbers, IPs)
│   ├── playbooks/
│   │   └── generate-configs.yml  # Ansible tasks
│   └── templates/
│       ├── daemons.j2
│       ├── spine/frr.conf.j2
│       ├── leaf/frr.conf.j2
│       ├── leaf/startup.sh.j2
│       └── clab/topology.yml.j2
└── scripts/
    └── verify.sh               # Automated health checks

# Generated at runtime (not in git):
├── configs/                    # Rendered FRR configs
└── evpn-lab.clab.yml          # Containerlab topology
✅ Verification Output
$ make verify

--- OSPF Neighbors (Spine1) ---
2.2.2.1    1 Full/-   29.629s  10.0.1.2    eth1
2.2.2.2    1 Full/-   34.630s  10.0.3.2    eth2
2.2.2.3    1 Full/-   29.629s  10.0.5.2    eth3

--- BGP EVPN Summary (Spine1) ---
10.0.1.2    4  65001  13  13  2  0  0  00:00:44  2  6 N/A
10.0.3.2    4  65002  13  13  2  0  0  00:00:44  2  6 N/A
10.0.5.2    4  65003  13  13  2  0  0  00:00:44  2  6 N/A

--- VXLAN Interface (Leaf1) ---
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ... state UNKNOWN

--- L2 Connectivity Test (Client1 -> Client2) ---
3 packets transmitted, 3 packets received, 0% packet loss

=========================================
Verification Complete
=========================================
🔧 Architecture Deep Dive
How Automation Works
┌─────────────────────────────────────────────────────────────────┐
│                      make deploy                                 │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Ansible Playbook (generate-configs.yml)                        │
│  ├── Reads inventory/lab.yml                                    │
│  ├── Renders Jinja2 templates → configs/                        │
│  │   ├── spine1/frr.conf                                        │
│  │   ├── leaf1/frr.conf + startup.sh                            │
│  │   └── ...                                                    │
│  └── Generates evpn-lab.clab.yml                                │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Containerlab Deployment                                        │
│  └── 8 containers (2 spines, 3 leaves, 3 clients)               │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Verification (make verify)                                     │
│  ├── OSPF neighbor check                                        │
│  ├── BGP EVPN summary                                           │
│  ├── VXLAN interface status                                     │
│  └── L2 connectivity ping test                                  │
└─────────────────────────────────────────────────────────────────┘
Why FRRouting?
FRRouting (FRR) is the open-source routing suite used by SONiC, Cumulus Linux, and DENT. By building this lab with FRR, the skills transfer directly to production open networking environments. The memory footprint is also significantly lower than proprietary NOS options (~200MB per leaf vs 2GB).
📚 References
Containerlab Documentation

FRRouting Documentation

EVPN/VXLAN Overview (RFC 8365)

📄 License
MIT - Feel free to use for learning, interviews, or production.

🙏 Acknowledgments
Built as part of a network automation learning journey. Special thanks to the FRRouting and Containerlab communities.
Questions or feedback? Open an issue or reach out on LinkedIn.

