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

##--- Virtual Machine configurations ---##
variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "node"
}
variable "vm_clone_id" {
  description = "Name of the Template VM we should use as the source to clone"
  type        = string
  default     = null
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