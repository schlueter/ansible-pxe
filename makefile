.PHONY: edit test cleane create_server destroy_server create_target delete_target vars

TARGET_VM=$(shell if [ -f pxe_target_name ] ; then cat pxe_target_name; else echo pxe_target_$$(date +%s) | tee pxe_target_name; fi)
SHARED_NETWORK=$(shell VBoxManage showvminfo $$(cat .vagrant/machines/default/virtualbox/id) | sed -n "s/^.*Host-only\ Interface\ \'\(.*\)\'.*/\1/p")

edit:
	find . -type f -not \( -name pxe_target_name -o -name *.jpg -o -name '*.vdi' -o -name *.retry -o -regex .*git.* -o -regex .*\.vagrant.* \) -exec vim {} +

test: | create_server create_target

clean: destroy_server delete_target

create_server:
	vagrant up

destroy_server:
	vagrant destroy -f

create_target:
	VBoxManage createhd --filename $(TARGET_VM).vdi --size 32768
	VBoxManage createvm --name $(TARGET_VM) --register --ostype Linux_64
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --add sata --controller IntelAHCI
	VBoxManage storageattach $(TARGET_VM) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $(TARGET_VM).vdi
	VBoxManage modifyvm $(TARGET_VM) --memory 2048
	VBoxManage modifyvm $(TARGET_VM) --nictype1 82540EM --hostonlyadapter1 $(SHARED_NETWORK) --nic1 hostonly
	VBoxManage modifyvm $(TARGET_VM) --nictype2 82540EM --nic2 nat
	VBoxManage modifyvm $(TARGET_VM) --boot4 net
	VBoxManage startvm $(TARGET_VM)

delete_target:
	if VboxManage list runningvms | grep $(TARGET_VM); then VBoxManage controlvm $(TARGET_VM) poweroff; fi
	@sleep 1
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --remove
	VBoxManage closemedium disk $(TARGET_VM).vdi --delete || no storage controller to delete
	VBoxManage unregistervm $(TARGET_VM) --delete
	rm pxe_target_name

vars:
	@echo TARGET_VM: $(TARGET_VM)
	@echo SHARED_NETWORK: $(SHARED_NETWORK)
