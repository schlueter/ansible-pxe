Vagrant.configure('2') do |config|
  HOSTNAME = 'pxe.local.rf29.net'
  IP_ADDR = '192.168.42.2'
  config.vm.box = 'ubuntu/xenial64'
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: IP_ADDR
  config.vm.provision 'shell',
    inline: 'apt-get update && apt-get install -y python-minimal',
    privileged: true
  config.vm.provision :ansible,
    playbook: 'playbooks/main.yml',
    groups: { pxe: %w(default)},
    sudo: true,
    verbose: 'vv',
    extra_vars: { download_dir: '/vagrant' }
end
