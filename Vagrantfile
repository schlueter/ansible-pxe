Vagrant.configure("2") do |config|
  config.vm.define :pxe_server do |server|
    HOSTNAME = "pxe.local"
    IP_ADDR = "192.168.42.2"
    server.vm.box = "ubuntu/trusty64"
    server.vm.hostname = HOSTNAME
    server.vm.network :private_network, ip: IP_ADDR, :adapter => 2, :host_only => 'vboxnet2'
    server.vm.provision :ansible, playbook: 'ansible/playbook.yml', sudo: true
  end
  config.vm.define :pxe_target do |target|
    target.vm.box = "blank"
    target.vm.network :private_network, :adapter => 1, :host_only => 'vboxnet2'
    target.vm.provider :virtualbox do |vbox|
      vbox.gui = true
    end
  end
end
