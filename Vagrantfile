# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, guest: 8083, host: 8083
  config.vm.network :forwarded_port, guest: 8086, host: 8086

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
  end
end
