resource "yandex_compute_instance" "kibana" {
  name = "kibana"
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
     subnet_id = yandex_vpc_subnet.web-sub-a.id
     nat = false
  }
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}

output "kibana"{
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}

#while zabbix agent not installed we're waiting
resource "null_resource" "provisioner_remote_exec_kbn" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = "yandex_compute_instance.zabbix.network_interface.0.nat_ip_address"
    }
  provisioner "remote-exec" {
    inline = ["while [ -n $(dpkg -l zabbix-agent 2>/dev/null) ]; do sleep 10; done"]
  }
}

resource "null_resource" "provisioner_local_exec_kbn" {
#HOST_CHECKING is because no host in known_hosts, hosts if for hosts file
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/hosts -u ${local.local_admin} --private-key ../id_rsa ../ansible/kibana.yml"
    on_failure = continue
  }
}
