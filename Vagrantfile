# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION = "2"

cfg = YAML.load_file('inventory.yml')

ssh_dirname = "ssh_config"
if !File.file?("#{ssh_dirname}/id_rsa.pub") 
  require 'openssl'
  require 'net/ssh'
  rsa_key = OpenSSL::PKey::RSA.new(2048) 
  unless File.directory?(ssh_dirname)
    FileUtils.mkdir_p(ssh_dirname)
  end
  File.open("#{ssh_dirname}/id_rsa", "w", 0600).write(rsa_key.to_s)
  type = rsa_key.public_key.ssh_type
  data = [ rsa_key.public_key.to_blob ].pack('m0')
  openssh_format = "#{type} #{data}"
  File.open("#{ssh_dirname}/id_rsa.pub", "w").write(openssh_format)
end
public_key_contents = File.open("ssh_config/id_rsa.pub").read.strip

boxname = "bento/ubuntu-16.04"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.provider "virtualbox" do |v|
  #  v.memory = 1024
  #end

  # setup the master node
  config.vm.define "master" do |master|
    master.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", "1024"]
          #vb.customize ["modifyvm", :id, "--cpus", "2"]
    end
    master.vm.box = boxname
    master.vm.synced_folder ".", "/vdata", owner: "vagrant", group: "vagrant"
    master.vm.network :private_network, ip: cfg['machines']['master']['ip']
    #    , netmask: "255.255.255.0",
    #    auto_config: true,
    #    virtualbox__intnet: "k8s-net"
    master.vm.provision :shell, inline: "echo #{public_key_contents} >> /home/vagrant/.ssh/authorized_keys"
  end

  # setup the worker nodes
  cfg["machines"]["workers"].each do |worker|
    config.vm.define worker["name"] do |w|
      w.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "2048"]
            #vb.customize ["modifyvm", :id, "--cpus", "2"]
      end
      w.vm.box = boxname
      w.vm.synced_folder ".", "/vdata", owner: "vagrant", group: "vagrant"
      w.vm.network :private_network, ip: worker["ip"]
      w.vm.provision :shell, inline: "echo #{public_key_contents} >> /home/vagrant/.ssh/authorized_keys"
    end
  end
end
