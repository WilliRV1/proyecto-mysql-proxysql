Vagrant.configure("2") do |config|
  # Configuración global
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end

  # ProxySQL
  config.vm.define "proxysql" do |proxysql|
  proxysql.vm.box = "ubuntu/focal64"
  proxysql.vm.hostname = "proxysql"
  proxysql.vm.network "private_network", ip: "192.168.50.30"
  proxysql.vm.provision "shell", path: "scripts/proxysql.sh"
  proxysql.vm.provision "shell", path: "scripts/proxysql-config.sh"
  proxysql.vm.provision "shell", path: "scripts/proxysql-complete-config.sh", run: "always"
end
  
 config.vm.define "mysql-master" do |master|
  master.vm.box = "ubuntu/focal64"
  master.vm.hostname = "mysql-master"
  master.vm.network "private_network", ip: "192.168.50.10"
  master.vm.provision "shell", path: "scripts/mysql-master.sh"
  #master.vm.provision "shell", path: "scripts/mysql-replicacion.sh"
end
  
  # MySQL Slave
  config.vm.define "mysql-slave" do |slave|
    slave.vm.box = "ubuntu/focal64"
    slave.vm.hostname = "mysql-slave"
    slave.vm.network "private_network", ip: "192.168.50.20"
    slave.vm.provision "shell", path: "scripts/mysql-slave.sh"
  end
end