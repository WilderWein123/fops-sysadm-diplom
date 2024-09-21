resource "yandex_vpc_network" "web-network" {
  name = "web-network"
}

resource "yandex_vpc_subnet" "web-sub-a" {
  name           = "web-sub-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.web-network.id
  v4_cidr_blocks = ["192.168.253.0/24"]
}

resource "yandex_vpc_subnet" "web-sub-b" {
  name           = "web-sub-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.web-network.id
  v4_cidr_blocks = ["192.168.254.0/24"]
}

resource "yandex_alb_target_group" "nginx-targetgroup" {
  name = "nginx-targetgroup"
  target {
    subnet_id = yandex_vpc_subnet.web-sub-a.id
    ip_address = yandex_compute_instance.nginx[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.web-sub-b.id
    ip_address = yandex_compute_instance.nginx[1].network_interface.0.ip_address
  }
}

resource "yandex_alb_load_balancer" "web-lb" {
  name = "web-lb"
  network_id = yandex_vpc_network.web-network.id
  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.web-sub-a.id
    }
    location {
      zone_id = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.web-sub-b.id
    }
  }
  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.webrouter.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "backend-group-nginx" {
  name = "backend-group-nginx"
  http_backend {
    name = "nginx-backend"
    port = "80"
  target_group_ids = [yandex_alb_target_group.nginx-targetgroup.id]
    healthcheck {
      timeout = "10s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "webrouter" {
  name      = "webrouter"
}

resource "yandex_alb_virtual_host" "nginx-virthost" {
  name = "nginx-virthost"
  http_router_id = yandex_alb_http_router.webrouter.id
  route {
    name = "nginx-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group-nginx.id
      }
    }
  }
  
}

output "load_balancer_ip" {
  value = yandex_alb_load_balancer.web-lb.listener.0.endpoint.0.address.0.external_ipv4_address[0].address
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tpl",
    {
      nginxes = yandex_compute_instance.nginx[*].network_interface.0.ip_address
      zabbix = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
      elastic = yandex_compute_instance.elastic.network_interface.0.ip_address
      kibana = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
    }
  )
  filename = "./hosts"
}


#while zabbix agent not installed we're waiting
resource "null_resource" "provisioner_remote_exec" {
  count = 2

    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = "${element(yandex_compute_instance.nginx[*].network_interface.0.nat_ip_address, count.index)}"
    }

  provisioner "remote-exec" {
    inline = ["while [ -n $(dpkg -l zabbix-agent 2>/dev/null) ]; do sleep 10; done"]
  }
}

resource "null_resource" "provisioner_local_exec" {
#HOST_CHECKING is because no host in known_hosts, hosts if for hosts file
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts -u ${local.local_admin} --private-key ../id_rsa nginx.yml"
#    on_failure = continue
  }
}