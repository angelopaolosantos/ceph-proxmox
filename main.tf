resource "tls_private_key" "ubuntu_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = "mkdir -p .ssh"
  }

  provisioner "local-exec" { # Copy a "myKey.pem" to local computer.
    command = "echo '${tls_private_key.ubuntu_private_key.private_key_pem}' | tee ${path.cwd}/.ssh/myKey.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${path.cwd}/.ssh/myKey.pem"
  }
}

resource "proxmox_virtual_environment_vm" "ceph_vm" {
  count = var.ceph_count
  name        = "ceph-vm-${count.index+1}"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu","ceph"]

  node_name = "pve01"

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_qcow2_img.id
    interface    = "scsi0"
    size = 25
  }

  initialization {
    datastore_id = "local-zfs"

    ip_config {
      ipv4 {
        address = "${var.ceph_ips[count.index]}/${var.network_range}"
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_private_key.public_key_openssh)]
      # password = random_password.ubuntu_vm_password.result
      password = "mypassword"
      username = var.vm_user
    }

    interface = "ide2"
  }

  machine = "q35"

  bios = "ovmf"

  efi_disk {
    datastore_id = "local-zfs"
    file_format = "raw"
    type = "4m"
  }

  cpu {
    cores = 4
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    model = "virtio"
    # vlan_id = 10
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_qcow2_img" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve01"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "ceph-ubuntu-amd64.img"
}

resource "random_password" "ubuntu_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# Ansible Section 

resource "ansible_host" "ceph_node" {
  name   = var.ceph_ips[count.index]
  groups = ["ceph"]

  variables = {
    ansible_user                 = var.vm_user
    ansible_ssh_private_key_file = "./.ssh/myKey.pem"
    ansible_python_interpreter   = "/usr/bin/python3"
    host_name                    = proxmox_virtual_environment_vm.ceph_vm[count.index].name 
    greetings                    = "from host!"
    some                         = "variable"
    private_ip                   = var.ceph_ips[count.index]
  }
  count = var.ceph_count
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file_new" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.
    # Generated by Terraform mgmt configuration.

    # tf_instance_ami: 
    # tf_aws_instance_controlplace_ip: 
    tf_monitor_ip = ${var.ceph_ips[0]}
    DOC
  filename = "./ansible/tf_ansible_vars_file.yaml"
}