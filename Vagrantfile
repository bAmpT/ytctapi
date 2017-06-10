# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

VM_NAME = "beam_vm"
MEMORY_SIZE_MB = 1024
NUMBER_OF_CPUS = 2

ENV["LC_ALL"] = "en_US.UTF-8"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.define "beam_vm" do |elixir_box|
    elixir_box.vm.provider "virtualbox" do |v|
      v.name = VM_NAME
      v.customize ["modifyvm", :id, "--memory", MEMORY_SIZE_MB]
      v.customize ["modifyvm", :id, "--cpus", NUMBER_OF_CPUS]
    end
    elixir_box.vm.network :private_network, ip: "192.168.55.55"
    elixir_box.vm.network :forwarded_port, guest: 5432, host: 45433
    elixir_box.vm.provision :shell, :path => "vagrant_provision.sh"
  end
end
