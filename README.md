# PXE, an Ansible framework
This repo provides an Ansible playbook which provisions a server to act as a PXE server from which machines may perform network installs of operating systems. Branches currently exist where either Ubuntu 16.04 or Centos 7 can be installed.

## Testing for Development
`make [clean] test` Will provision the pxe server and start a Virtual Box instance which will PXE install the first available option.
