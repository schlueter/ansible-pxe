Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local.rf29.net"
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
    verbose: 'vv',
    extra_vars: {
      dnsmasq_interface: 'eth1',
      dnsmasq_dhcp_range: '192.168.42.102,192.168.42.102',
      dnsmasq_router: '192.168.42.1',
      dnsmasq_server: '8.8.8.8',
      dnsmasq_no_dhcp_interfaces: [],
      dnsmasq_only_known_hosts: false,
      dnsmasq_dhcp_hosts: [],
      dnsmasq_dhcp_boot: IP_ADDR,
      pxe_kickstart_host: "#{IP_ADDR}:8080",
      nginx_network_install_port: 8080,
      install_isos: [{
        name: 'CentOS-7-x86_64-Minimal-1511',
        url: 'http://mirror.lug.udel.edu/pub/centos/7/isos/x86_64',
        checksum: 'md5:88c0437f0a14c6e2c94426df9d43cd67',
        kernel: 'vmlinuz',
        initrd: 'initrd.img',
        boot_files: %w(isolinux/vmlinuz isolinux/initrd.img)
			}],
      kickstart_host_vars: {
        'server' => { url: "http://#{IP_ADDR}:8080/isos/CentOS-7-x86_64-Minimal-1511" },
        '192.168.42.102' => {
          hostname: 'target.pxe.local',
          # usually this is better
          # install_drive: '/dev/disk/by-path/pci-0000:00:01.1-ata-1.0',
          install_drive: '/dev/sda',
          networks: [{
            device: 'enp0s3',
            bootproto: 'static',
            ip: '192.168.42.102',
            netmask: '255.255.255.0'
          }, {
            device: 'br0',
            bridgeslaves: 'enp0s8',
            bootproto: 'dhcp'
          }]
        }
      }
    }
end
