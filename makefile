.PHONY: edit test clean create_server destroy_server create_target delete_target vars help

TARGET_VM=$(shell if [ -f pxe_target_name ] ; then cat pxe_target_name; else echo pxe_target_$$(date +%s) | tee pxe_target_name; fi)
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	SHARED_NETWORK=$(shell VBoxManage showvminfo $$(cat .vagrant/machines/default/virtualbox/id) | sed -n "s/.*Host-only\ Interface\ '\(.*\)'.*/\1/p")
endif
ifeq ($(UNAME_S),Darwin)
	SHARED_NETWORK=$(shell VBoxManage showvminfo $$(cat .vagrant/machines/default/virtualbox/id) | sed -n "s/^.*Host-only\ Interface\ \'\(.*\)\'.*/\1/p")
endif

vars: ## List the variables used by this makefile with their values
	$(foreach v,                                        \
		$(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), \
		$(info $(v) = $($(v))))
	@# Thanks Ise Wisteria (borrowed from https://stackoverflow.com/a/7119460/1054423)
	@# These comments prevent the "make: Nothing to be done for 'vars'." message

help: ## Show this help
	@# print all lines from make files which begin with #^
	@sed -n 's/^#\^ \?//p' $(MAKEFILE_LIST)
	@# find all lines in make files containing ##, sort them, remove lines containing "##", then pretty print them
	@grep -h "## " $(MAKEFILE_LIST) | sort | awk -F ' ## ' ' \
		!/"## "/ { \
			gsub(":.*", "", $$1); \
			printf "%10s :: %s\n", $$1, $$2; \
	  }'
	@# print all lines from make files which begin with #$
	@sed -n 's/^#$$ \?//p' $(MAKEFILE_LIST)

edit: ## Edit source files
	@find . -type f -not \( \
		 -name 'pxe_target_name' \
	-o -name '*.jpg' \
	-o -name '*.vdi' \
	-o -name '*.retry' \
	-o -name 'id_*' \
	-o -name '*.iso' \
	-o -name '*.log' \
	-o -name 'memtest86*' \
	-o -regex '.*git.*' \
	-o -regex '.*\.vagrant.*' \
	\) -exec $$EDITOR {} +

test: | create_server create_target ## Launch a VM hosting a PXE server and then launch a blank VM and install the default option from pxe on it
	@sleep 30
	@echo wait for the target
	@until ! vboxmanage list runningvms | grep $(TARGET_VM) >/dev/null ; do sleep 1; done
	@sleep 30
	VBoxManage startvm $(TARGET_VM)
	@sleep 30
	@echo "Test machine is ready!"
	@chmod 600 ssh/id_ed25519
	@echo "Try ssh root@$$(vagrant ssh -c 'PAGER=cat sudo -E systemctl status dnsmasq -o cat' | awk '/kickseed/{print $$2}') -i ssh/id_ed25519"

clean: destroy_server delete_target ## ..

create_server: ## Create a VM hosting a PXE server
	vagrant up

destroy_server: ## Destroy PXE server VM
	vagrant destroy -f

# the order of nic creation matters here, net boot tries in order
create_target: ## Launch a blank target VM
	VBoxManage createhd --filename $(TARGET_VM).vdi --size 32768
	VBoxManage createvm --name $(TARGET_VM) --register --ostype Linux_64
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --add sata --controller IntelAHCI
	VBoxManage storageattach $(TARGET_VM) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $(TARGET_VM).vdi
	VBoxManage modifyvm $(TARGET_VM) --memory 2048
	VBoxManage modifyvm $(TARGET_VM) --nictype1 82540EM --nic1 hostonly --hostonlyadapter1 $(SHARED_NETWORK)
	VBoxManage modifyvm $(TARGET_VM) --nictype2 82540EM --nic2 nat
	VBoxManage modifyvm $(TARGET_VM) --boot4 net
	VBoxManage startvm $(TARGET_VM)

destroy_target: ## Delete target VM
	if VBoxManage list runningvms | grep $(TARGET_VM); then VBoxManage controlvm $(TARGET_VM) poweroff; sleep 10; fi
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --remove
	VBoxManage closemedium disk $(TARGET_VM).vdi --delete || no storage controller to delete
	VBoxManage unregistervm $(TARGET_VM) --delete
	rm pxe_target_name
