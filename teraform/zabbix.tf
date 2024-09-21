resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd833v6c5tb0udvk4jo6"
      size=10
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    index = 0
    subnet_id = yandex_vpc_subnet.web-sub-a.id
    nat = true
    }
  
  network_interface {
    index = 9
    subnet_id = yandex_vpc_subnet.local-sub-c.id
  }

  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}


output "zabbix_ext"{
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "zabbix_int"{
  value = yandex_compute_instance.zabbix.network_interface.9.ip_address
}

#while zabbix agent not installed we're waiting
#resource "null_resource" "provisioner_remote_exec_zbx" {
#    connection {
#      type        = "ssh"
#      user        = local.local_admin
#      private_key = file(local.local_admin_private_key)
#      host = "yandex_compute_instance.zabbix.network_interface.0.nat_ip_address"
#    }
#  provisioner "remote-exec" {
#    inline = ["while [ -n $(dpkg -l zabbix-agent 2>/dev/null) ]; do sleep 10; done"]
#  }
#}
#
#resource "null_resource" "provisioner_local_exec_zbx" {
#HOST_CHECKING is because no host in known_hosts, hosts if for hosts file
#  provisioner "local-exec" {
#    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/hosts -u ${local.local_admin} --private-key ../id_rsa ../ansible/zabbix.yml"
#    on_failure = continue
#  }
#}
