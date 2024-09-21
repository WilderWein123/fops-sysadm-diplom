resource "yandex_compute_instance" "nginx" {
  count = 2
  name = "nginx${count.index + 1}"
  zone = "ru-central1-${count.index == 0? "a" : "b"}"

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
     subnet_id = count.index == 0? yandex_vpc_subnet.web-sub-a.id : yandex_vpc_subnet.web-sub-b.id
     nat = false
  }
  
  metadata = {
    user-data = "${file("cloud_conf_int.yaml")}"
  }
}

output "nginx_ips" {
  value = tomap ({
    for name, nginx in yandex_compute_instance.nginx : name => nginx.network_interface.0.ip_address
  })
}

