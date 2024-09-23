resource "yandex_vpc_security_group" "secgroup_zabbix" {
    network_id = yandex_vpc_network.web-network.id
    name = "secgroup_zabbix"

    ingress {
        protocol = "TCP"
        port = "80"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "secgroup_kibana" {
    network_id = yandex_vpc_network.web-network.id
    name = "secgroup_kibana"

    ingress {
        protocol = "TCP"
        port = "5601"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "secgroup-mgmt" {
    name = "secgroup-mgmt"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}