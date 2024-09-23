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
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}


output "zabbix_ext"{
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}
