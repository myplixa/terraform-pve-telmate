##--- Global params configuration ---##
variable "node_name" {
  description = "Target PVE node to deploy VM"
  type        = string
  default     = "pve"
}
variable "pool_name" {
  description = "Target Pool name for VM(s)"
  type        = string
  default     = null
}
variable "vm_tags" {
  description = "List of virtual machine tags"
  type        = string
  default     = null
}
variable "vm_description" {
  description = "Owner, purpose and other description of the VM(s)"
  type        = string
  default     = null
}
variable "vm_count" {
  description = "Count of VM(s) to be deployed"
  type        = number
  default     = 1
}
##--- Virtual Machine information ---##
variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "node"
}
variable "template_name" {
  description = "Neme or ID of the template VM"
  type        = string
  default     = null
}
variable "template_id" {
  description = "Neme or ID of the template VM"
  type        = number
  default     = null
}

##--- Virtual Machine configurations ---##
variable "qemu_os" {
  type = string
  default = "l26"
}
variable "machine" {
  type = string
  default = "q35"
}

variable "resources" {
  type = object({
    sockets  = optional(number, 1)
    cores    = optional(number, 1)
    cpu_type = optional(string, "host")
    memory   = optional(number, 1)
  })
}

##--- Disk configuration ---#
variable "disk" {
  type = object({
    system_size  = optional(number, 10)
    data_sizes   = optional(string, "")
    storage_name = optional(string, "local-zfs")
    format       = optional(string, "raw")
  })
}

##--- Network Interface configuration ---#
variable "network" {
  type = object({
    bridge_name = optional(string, "vmbr0")
    model       = optional(string, "virtio")
    vlan_id     = optional(number, null)
    ip_address  = optional(string, null)
    gw_address  = optional(string, null)
    dns         = optional(string, null)
    domain_name = optional(string, null)
  })
}

##--- Cloud-Init configuration ---##
variable "cloud_init" {
  type = object({
    os_upgrade        = optional(bool, false)
    cloudinit_file    = optional(string, null)
    ssh_username      = optional(string, null)
    ssh_password      = optional(string, null)
    ssh_user_key_file = optional(string, null)
  })
}