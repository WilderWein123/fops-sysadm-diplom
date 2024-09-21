resource "yandex_compute_instance" "bastion" {
  name = "bastion"
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
     nat = true
  }
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}


output "zabbix"{
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

#while zabbix agent not installed we're waiting
resource "null_resource" "provisioner_remote_exec_bst" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = "yandex_compute_instance.zabbix.network_interface.0.nat_ip_address"
    }
  provisioner "remote-exec" {
    inline = ["while [ -n $(dpkg -l zabbix-agent 2>/dev/null) ]; do sleep 10; done"]
  }
  provisioner "file" {
    source = "../ansible"
    destination = "/tmp/"
  }
}
