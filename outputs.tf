output "vm_name" {
  description = "The current VM name"
  value       = proxmox_vm_qemu.deploy_vm.*.name
}
output "vm_ip_address" {
  description = "The current IP address of the VM"
  value       = proxmox_vm_qemu.deploy_vm.*.default_ipv4_address
}