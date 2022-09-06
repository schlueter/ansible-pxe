Vagrant.configure('2') do |config|
  HOSTNAME = 'pxe.local'
  IP_ADDR = '192.168.56.2'
  config.vm.box = 'ubuntu/xenial64'
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR
  config.vm.provision 'shell',
    inline: 'apt-get install -y python-minimal',
    privileged: true
  config.vm.provision :ansible,
    playbook: 'playbooks/pxe.yml',
    groups: { pxe: %w(default)},
    raw_arguments: %w(-vv --diff --become),
    extra_vars: { download_dir: '/vagrant',
                  pxe_target_interface: 'enp0s8' }
end
