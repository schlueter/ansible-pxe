Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local.rf29.net"
  IP_ADDR = "192.168.42.2"
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = HOSTNAME
  config.vm.network "private_network", ip: IP_ADDR

  config.vm.provision :ansible,
    playbook: 'ansible/playbook.yml',
    sudo: true,
    ask_sudo_pass: true,
    extra_vars: { guest_ip_address: IP_ADDR, guest_hostname: HOSTNAME }

end
