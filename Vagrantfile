Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local.rf29.net"
  IP_ADDR = "192.168.42.2"
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR

  config.vm.provision :ansible,
    playbook: 'ansible/playbook.yml',
    sudo: true,
    verbose: 'vv',
    extra_vars: {
      dnsmasq_interface: 'eth1',
      dnsmasq_dhcp_range: '192.168.42.10,192.168.42.20',
      dnsmasq_router: '192.168.42.1',
      dnsmasq_server: '8.8.8.8',
      dnsmasq_hosts: [],
      pxe_kickstart_host: IP_ADDR,
      kickstart_url: "http://#{IP_ADDR}",
      kickstart_logging_host: IP_ADDR,
      kickstart_hostname: 'target.pxe.local',
      kickstart_install_drive: '/dev/disk/by-path/pci-0000:00:0d.0-ata-1.0',
      kickstart_networks: [{
        device: 'enp0s3',
        bootproto: 'static',
        ip: '192.168.42.101',
        netmask: '255.255.255.0'
      }, {
        device: 'br0',
        bridgeslaves: 'enp0s8',
        bootproto: 'dhcp'
      }]
    }
end
