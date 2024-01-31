##--- Start of global Virtual Machine params description ---##
variable "node_name" {
  description = "Target PVE node to deploy VM"
  type        = list(string)
  default     = ["pve"]
}
variable "pool_name" {
  description = "Target Pool name for VM(s)"
  type        = string
  default     = null
}
variable "tags_vm" {
  description = "List of virtual machine tags"
  type        = list(string)
  default     = [""]
}
variable "description_vm" {
  description = "Owner, purpose and other description of the VM(s)"
  type        = string
  default     = null
}
variable "count_vm" {
  description = "Count of VM(s) to be deployed"
  type        = number
  default     = 1
}
##--- End region ---##

##--- Start Virtual Machine configurations description ---##
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
variable "vm_cpu_type" {
  description = "Modeless CPU"
  type        = string
  default     = "host"
}
variable "vm_cores" {
  description = "Count of cores to be deployed"
  type        = number
  default     = 2
}
variable "vm_memory" {
  description = "Count of memory to be deployed"
  type        = number
  default     = 4096
}
variable "vm_disk_sizes" {
  description = "Size of the disk in GigaBytes"
  type        = list(string)
  default     = ["10G"]
}
variable "vm_storage_name" {
  description = "Name of the PVE storage that will used to store our VM"
  type        = string
  default     = "local-zfs"
}
##--- End region ---#

##--- Start Network Interface configuration ---#
variable "vm_newtwork_bridge_name" {
  description = "VM bridge interface name"
  type        = string
  default     = "vmbr0"
}
variable "vm_network_vlan_id" {
  description = "VLAN ID to assign to VM"
  type = number
  default = null
}
##--- End region ---#

##--- Start description of Cloud-Init variables ---##
variable "vm_user_name" {
  description = "Override default cloud-init user for provisioning"
  type        = string
  default     = null
}
variable "vm_user_password" {
  description = "Override default cloud-init user's password. Please, use \"Sensitive\" param!"
  type        = string
  sensitive   = true
  default     = null
}
variable "vm_search_domain" {
  description = "Sets default DNS search domain suffix."
  type        = string
  default     = null
}
variable "vm_dns" {
  description = "Sets default DNS server for QEMU GuestAgent"
  type        = list(string)
  default     = null
}
variable "vm_network_ip_address" {
  description = "IP address to assign to QEMU GuestAgent"
  type        = string
  default     = null
}
variable "vm_network_gw_adress" {
  description = "IP address of default gateway"
  type        = string
  default     = null
}
variable "vm_user_ssh_key_file" {
  description = "Newline delimited list of SSH public keys to add to authorized keys file for the user created from the \"vm_user_name\" parameter"
  type        = string
  sensitive   = true
  default     = null
}
##--- End region ---##
