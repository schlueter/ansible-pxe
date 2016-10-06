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
      kickstart_logging_host: IP_ADDR
    }
end
