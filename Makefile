.PHONY: deploy destroy verify clean

TOPOLOGY := evpn-lab.clab.yml

deploy:
	sudo containerlab deploy -t $(TOPOLOGY)
	@echo ""
	@echo "Waiting for OSPF/BGP convergence (30 seconds)..."
	sleep 30
	@echo ""
	@echo "✓ Lab deployed successfully!"
	@echo "  Run 'make verify' to test connectivity."
	@echo "  Container prefix: clab-evpn-lab-auto-"

destroy:
	sudo containerlab destroy -t $(TOPOLOGY)

verify:
	./scripts/verify.sh

clean: destroy
	rm -rf configs/spine1/*.conf configs/spine2/*.conf
	rm -rf configs/leaf1/*.conf configs/leaf2/*.conf configs/leaf3/*.conf
	@echo "✓ Cleaned generated configs"
