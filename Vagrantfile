Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local.rf29.net"
  IP_ADDR = "192.168.42.2"
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR
  config.vm.provision :file, source: "~/Downloads/CentOS-7-x86_64-Minimal-1511.iso", destination: "/home/vagrant/CentOS-7-x86_64-Minimal-1511.iso"
  config.vm.provision :file, source: "~/Downloads/memtest86+-5.01.bin.gz", destination: "/home/vagrant/memtest86+-5.01.bin.gz"
  config.vm.provision :ansible,
    playbook: 'ansible/playbook.yml',
    sudo: true,
    verbose: 'vv',
    extra_vars: {
      dnsmasq_interface: 'eth1',
      dnsmasq_dhcp_range: '192.168.42.102,192.168.42.102',
      dnsmasq_router: '192.168.42.1',
      dnsmasq_server: '8.8.8.8',
      dnsmasq_hosts: [],
      pxe_kickstart_host: IP_ADDR,
      kickstart_host_vars: {
        server: { url: "http://#{IP_ADDR}" },
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
