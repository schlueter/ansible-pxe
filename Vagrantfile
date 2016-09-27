Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "private_network", ip: "192.168.42.2"

  config.vm.provision :ansible,
    playbook: 'ansible/playbook.yml',
    sudo: true
end
