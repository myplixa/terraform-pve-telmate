output "vm_name" {
  description = "List of VM names"
  value       = [for vm in proxmox_vm_qemu.deploy_vm : vm.name]
}

output "ip_address" {
  description = "List of VM IP addresses"
  value       = [for vm in proxmox_vm_qemu.deploy_vm : vm.default_ipv4_address]
}

output "vm_info" {
  value = {
    for k, vm in proxmox_vm_qemu.deploy_vm :
    vm.name => {
      ip           = try(vm.default_ipv4_address, null)
      macaddr      = try(vm.network[0].macaddr, null)
      gateway      = try(var.network.gw_address, null)
      domain_name  = try(var.network.domain_name, null)
      fqdn         = try("${var.vm_name}.${var.network.domain_name}", null)
      tags         = try(var.vm_tags, null)
      ssh_user     = try(var.cloud_init.ssh_username, null)
      ssh_password = try(var.cloud_init.ssh_password, null)
    }
  }
}