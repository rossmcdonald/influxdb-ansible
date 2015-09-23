# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  # config.vm.box = "puppetlabs/centos-6.6-64-nocm"
  # config.vm.box = "hansode/centos-6.5-x86_64"

  # InfluxDB ports
  config.vm.network :forwarded_port, guest: 8083, host: 8083
  config.vm.network :forwarded_port, guest: 8086, host: 8086

  # Grafana ports
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "site.yml"
  end
end
