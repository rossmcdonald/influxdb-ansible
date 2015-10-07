# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  # config.vm.box = "ubuntu/vivid64"
  # config.vm.box = "relativkreativ/centos-7-minimal"
  # config.vm.box = "box-cutter/fedora22"
  # config.vm.box = "puppetlabs/centos-6.6-64-nocm"
  # config.vm.box = "hansode/centos-6.5-x86_64"

  BOX_COUNT = 1
  (1..BOX_COUNT).each do |machine_id|
    config.vm.define "influx#{machine_id}" do |machine|
      machine.vm.hostname = "influx#{machine_id}"
      # machine.vm.network "private_network", ip: "10.0.3.#{1+machine_id}", virtualbox__intnet: true
      machine.vm.network "public_network", :bridge => 'en0: Wi-Fi (AirPort)'
      
      # # InfluxDB ports
      # config.vm.network :forwarded_port, guest: 8083, host: 8083+machine_id
      # config.vm.network :forwarded_port, guest: 8086, host: 8086+machine_id
      
      # Grafana ports
      # config.vm.network :forwarded_port, guest: 3000, host: 3000
      
      machine.vm.provider "virtualbox" do |v|
        v.memory = 512
        v.cpus = 1
      end

      if machine_id == BOX_COUNT
        machine.vm.provision "ansible" do |ansible|
          # ansible.verbose = 'vvvv'
          ansible.limit = 'all'
          ansible.playbook = "site.yml"
        end
      end
      
    end
  end
end
