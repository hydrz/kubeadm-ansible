Vagrant.require_version ">= 1.7.0"

$os_image = (ENV['OS_IMAGE'] || "centos").to_sym

def set_vbox(vb, config)
  vb.gui = false
  vb.memory = 2048
  vb.cpus = 2

  case $os_image
  when :centos
    config.vm.box = "centos/7"
  when :ubuntu
    config.vm.box = "ubuntu/bionic64"
  end
end

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  master = 1
  node = 1

  private_count = 10 + master + node - 1
  (1..(master + node)).each do |mid|
    name = (mid <= node) ? "n" : "m"
    id   = (mid <= node) ? mid : (mid - node)

    config.vm.define "k8s-#{name}#{id}" do |n|
      n.vm.hostname = "k8s-#{name}#{id}"
      ip_addr = "192.168.15.#{private_count}"
      n.vm.network :private_network, ip: "#{ip_addr}",  auto_config: true

      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override)
      end
      private_count -= 1
    end
  end

  # Install of dependency packages using script
  config.vm.provision :shell, inline: "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config &&  systemctl restart sshd"
end
