.PHONY: edit test destroy vm_name

TARGET_VM=$(shell if [ -f pxe_target_name ] ; then cat pxe_target_name; else echo pxe_target_$$(date +%s) | tee pxe_target_name; fi)

edit:
	find . -type f -not \( -name *.jpg -o -name '*.vdi' -o -name *.retry -o -regex .*git.* -o -regex .*\.vagrant.* \) -exec vim {} +

test:
	VBoxManage showvminfo $(cat .vagrant/machines/default/virtualbox/id) | awk '/Host-only Interface/'
	VBoxManage createhd --filename $(TARGET_VM).vdi --size 32768
	VBoxManage createvm --name $(TARGET_VM) --register --ostype Linux_64
	VBoxManage modifyvm $(TARGET_VM) --hostonlyadapter1 vboxnet2
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --add sata --controller IntelAHCI --bootable on
	VBoxManage storageattach $(TARGET_VM) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $(TARGET_VM).vdi
	VBoxManage modifyvm $(TARGET_VM) --memory 2048
	VBoxManage modifyvm $(TARGET_VM) --nictype1 82540EM --hostonlyadapter1 vboxnet2 --nic1 hostonly
	VBoxManage modifyvm $(TARGET_VM) --nictype2 82540EM --nic2 nat
	VBoxManage modifyvm $(TARGET_VM) --boot1 net
	VBoxManage startvm $(TARGET_VM)

destroy:
	if VboxManage list runningvms | grep $(TARGET_VM); then VBoxManage controlvm $(TARGET_VM) poweroff; fi
	@sleep 1
	VBoxManage storagectl $(TARGET_VM) --name "SATA Controller" --remove
	VBoxManage closemedium disk $(TARGET_VM).vdi --delete || no storage controller to delete
	VBoxManage unregistervm $(TARGET_VM) --delete
	rm pxe_target_name

vm_name:
	@echo $(TARGET_VM)
