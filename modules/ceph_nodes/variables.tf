variable "ceph_count" {
    type = number
    default = 3
}

variable "ceph_ips" {
    type = list(string)
    default = [
        "192.168.254.109",
        "192.168.254.110",
        "192.168.254.111",
    ]
}

variable "file_id" {
  type = string  
}

variable "public_key_openssh" {
    type = string
}

variable "network_range" {
    type = string
    default = "24"
}

variable "gateway" {
    type = string
    default = "192.168.254.254"
    description = "network gateway"
}

variable "vm_user" {
    type = string
    default = "ceph"
}

variable "ceph_allowed_access_ip" {
    type = string
    default = "192.168.254.0/24"
}