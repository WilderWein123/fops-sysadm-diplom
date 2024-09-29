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
     security_group_ids =  [ yandex_vpc_security_group.out_all.id, yandex_vpc_security_group.inc_ssh_global.id ]
  }
  
  metadata = {
    user-data = "${file("cloud_conf_bastion.yaml")}"
  }
}


output "bastion_ext"{
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

#while zabbix agent not installed we're waiting
resource "null_resource" "waiting_vm_started" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
  provisioner "remote-exec" {
    inline = ["while [ -n $(dpkg -l apt 2>/dev/null) ]; do echo 'waiting for VM started' && sleep 10; done"]
  }
}

resource "null_resource" "provisioning_files" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
  provisioner "file"{
    source = "../ansible"
    destination = "/tmp"
  }
#  provisioner "file" {
#    source = "/data/distribs/Linux/elasticsearch/"
#    destination =  "/tmp/"
#  }
}

resource "null_resource" "installing_ansible" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
  provisioner "remote-exec" {
    inline = [
      "apt update"
      "apt upgrade -y"
      "apt autoremove"
      "sudo chmod 600 /tmp/ansible/id_rsa"
    ]
  }
}

resource "null_resource" "starting_playbooks" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
  provisioner "remote-exec" {
    inline = ["while [ -n $(dpkg -l ansible 2>/dev/null) ]; do echo 'waiting for ansible installed' && sleep 10; done"]
  }
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/nginx.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/elastic.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/kibana.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/zabbix.yml"
#      ,
#      "rm -rf /tmp/ansible"
    ]
  }
}
