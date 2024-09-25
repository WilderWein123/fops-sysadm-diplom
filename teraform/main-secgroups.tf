resource "yandex_vpc_security_group" "inc_web" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_web"

    ingress {
        protocol = "TCP"
        port = "80"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_kibana" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_kibana"

    ingress {
        protocol = "TCP"
        port = "5601"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_elk" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_elk"

    ingress {
        protocol = "TCP"
        port = "9200"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_ssh_global" {
    name = "inc_ssh_global"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "out_all" {
    name = "out_all"
    network_id = yandex_vpc_network.web-network.id
    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 65535
    }
}

resource "yandex_vpc_security_group" "local_all" {
    name = "local_all"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "ANY"
        v4_cidr_blocks = ["192.168.0.0/16"]
        from_port = 0
        to_port = 65535
    }
    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["192.168.0.0/16"]
        from_port = 0
        to_port = 65535
    }
}
