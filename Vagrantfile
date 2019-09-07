CLUSTER_OS_BOX="centos/7"
MASTER_RAM_MB="1024"
SLAVE_RAM_MB="2048"
MASTERS = { "master" => "192.168.10.10" }
SLAVES = { "slave-0" => "192.168.10.20", "slave-1" => "192.168.10.21", "slave-2" => "192.168.10.22" }

Vagrant.configure("2") do |config|

  MASTERS.each do |master, ip|
    config.vm.define master do |master|
      master.vm.box = CLUSTER_OS_BOX
      master.vm.hostname = ip
      master.vm.network "private_network" , ip: ip
      master.vm.provision "file", source: "provision/hosts", destination: "/tmp/hosts"
      master.vm.provision "file", source: "bundles/hadoop.tar.gz"
      master.vm.provision "shell", path: "provision/bootstrap.sh"
      master.vm.provider "virtualbox" do |v|
        v.name = master.to_s
        v.memory = MASTER_RAM_MB
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
      end
    end
  end

  SLAVES.each do |slave, ip|
    config.vm.define slave do |slave|
      slave.vm.box = CLUSTER_OS_BOX
      slave.vm.hostname = ip
      slave.vm.network "private_network", ip: ip
      slave.vm.provision "file", source: "provision/hosts", destination: "/tmp/hosts"
      slave.vm.provision "shell", path: "provision/bootstrap.sh"
      slave.vm.provider "virtualbox" do |v|
        v.name = slave.to_s
        v.memory = SLAVE_RAM_MB
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
      end
  end

end
