.PHONY: generate deploy destroy verify clean

TOPOLOGY := evpn-lab.clab.yml
INVENTORY := automation/inventory/lab.yml
PLAYBOOK := automation/playbooks/generate-configs.yml

# Generate configs using Ansible
generate:
	@echo "📝 Generating configurations with Ansible..."
	cd automation && ansible-playbook -i inventory/lab.yml playbooks/generate-configs.yml
	@echo "✓ Configurations generated in configs/"

# Deploy the lab
deploy: generate
	@echo ""
	@echo "🚀 Deploying lab with Containerlab..."
	sudo containerlab deploy -t $(TOPOLOGY)
	@echo ""
	@echo "Waiting for OSPF/BGP convergence (30 seconds)..."
	sleep 30
	@echo ""
	@echo "✓ Lab deployed successfully!"
	@echo "  Run 'make verify' to test connectivity."

# Destroy the lab
destroy:
	sudo containerlab destroy -t $(TOPOLOGY)

# Verify connectivity
verify:
	./scripts/verify.sh

# Clean everything
clean: destroy
	rm -rf configs/
	rm -f $(TOPOLOGY)
	@echo "✓ Cleaned configs and topology file"

# Full reload
reload: clean deploy

# Help
help:
	@echo "Available targets:"
	@echo ""
	@echo "  make generate  - Generate configs from Ansible templates"
	@echo "  make deploy    - Generate configs + deploy lab"
	@echo "  make destroy   - Destroy the lab"
	@echo "  make verify    - Run connectivity tests"
	@echo "  make clean     - Destroy lab + remove generated files"
	@echo "  make reload    - Full clean + redeploy"
