Vagrant.configure("2") do |config|
  HOSTNAME = "pxe.local.rf29.net"
  IP_ADDR = "192.168.42.2"
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR
  config.vm.provision "shell",
    inline: 'apt-get update && apt-get install -y python-minimal',
    privileged: true
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
        name: 'CentOS-7-x86_64-Minimal',
        url: 'https://buildlogs.centos.org/rolling/7/isos/x86_64',
        checksum: 'md5:19193aa7831f35f32dc0f1fc7fb6fc3e',
        kernel: 'vmlinuz',
        initrd: 'initrd.img',
        boot_files: %w(isolinux/vmlinuz isolinux/initrd.img)
			},{
        name: 'Ubuntu-Xenial-amd64-netboot',
        filename: 'mini',
        url: 'http://archive.ubuntu.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot',
        checksum: 'md5:fe495d34188a9568c8d166efc5898d22',
        kernel: 'linux',
        initrd: 'initrd.gz',
        boot_files: %w(linux initrd.gz)
      }],
      kickstart_host_vars: {
        'server' => { centos_7_x86_64: { url: "http://#{IP_ADDR}:8080/isos/CentOS-7-x86_64-Minimal" },
                      ubuntu_xenial_amd64: { url: "http://mirror.math.princeton.edu/pub/ubuntu/" }},
        '192.168.42.102' => {
          hostname: 'target.pxe.local',
          # usually this is better
          # install_drive: '/dev/disk/by-path/pci-0000:00:01.1-ata-1.0',
          install_drive: '/dev/sda',
          networks: [{
            device: 'enp0s3',
            bootproto: 'dhcp',
          }]
        }
      }
    }
end
