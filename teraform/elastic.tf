resource "yandex_compute_instance" "elastic" {
  name = "elastic"
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
     subnet_id = yandex_vpc_subnet.local-sub-c.id
     index = 9
  }
  
  metadata = {
    user-data = "${file("cloud_conf_int.yaml")}"
  }
}

output "elastic_int"{
  value = yandex_compute_instance.elastic.network_interface.9.ip_address
}

