Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local"
  IP_ADDR = "192.168.42.2"
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR
  if File.file?('~/Downloads/CentOS-7-x86_64-Minimal-1511.iso')
      config.vm.provision :file, source: '~/Downloads/CentOS-7-x86_64-Minimal-1511.iso', destination: "/home/vagrant/CentOS-7-x86_64-Minimal-1511.iso"
  end
  if File.file?('memtest86+-5.01.bin.gz')
      config.vm.provision :file, source: "~/Downloads/memtest86+-5.01.bin.gz", destination: "/home/vagrant/memtest86+-5.01.bin.gz"
  end
  config.vm.provision :ansible,
      playbook: 'ansible/playbook.yml',
      sudo: true,
      extra_vars: { IP_ADDR: IP_ADDR }
end
