output "name" {
  value = proxmox_virtual_environment_vm.ceph_vm.*.name
  description = ""
}

output "ip" {
value = var.ceph_ips
  description = ""
}

output "ceph_count" {
  value = var.ceph_count
  description = ""
}

output "vm_user" {
  value = var.vm_user
  description = ""
}

output "ceph_allowed_access_ip" {
  value = var.ceph_allowed_access_ip
  description = ""
}