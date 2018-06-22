# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure("2") do |config|
  config.vm.box = "freebsd/FreeBSD-11.1-STABLE"
  config.vm.guest = :freebsd
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.base_mac = "5254006B0EFF"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", `awk "/^processor/ {++n} END {print n}" /proc/cpuinfo 2> /dev/null || sh -c 'sysctl hw.logicalcpu 2> /dev/null || echo ": 2"' | awk \'{print \$2}\' `.chomp]
    vb.customize ["modifyvm", :id, "--paravirtprovider", "default"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

  config.ssh.shell = 'sh'
  config.vm.provision "optionsdir", type: "file", source: "work/options", destination: "/tmp/options"
  config.vm.provision "portsfile", type: "file", source: "work/ports.list", destination: "/tmp/ports.list"
  config.vm.provision "installonly", type: "shell", path: "build.sh", args: "installonly"
  config.vm.provision "builder", type: "shell", path: "build.sh", args: "poudriere"
end
