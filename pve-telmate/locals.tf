locals {
  node_name      = var.node_name
  pool_name      = var.pool_name
  count_vm       = var.count_vm
  description_vm = var.description_vm
  tags_vm        = var.tags_vm

  vm_name         = var.vm_name
  vm_clone_id     = var.vm_clone_id
  vm_cpu_type     = var.vm_cpu_type
  vm_cores        = var.vm_cores
  vm_memory       = var.vm_memory
  vm_disk_sizes   = var.vm_disk_sizes
  vm_storage_name = var.vm_storage_name

  # Network interface parameters
  vm_newtwork_bridge_name = var.vm_newtwork_bridge_name
  vm_network_vlan_id = var.vm_network_vlan_id

  # Cloud-Init
  vm_user_name     = var.vm_user_name
  vm_user_password = var.vm_user_password
  vm_search_domain = var.vm_search_domain
  vm_dns           = var.vm_dns
  vm_network_config = [
    var.vm_network_ip_address != null ? "ip=${var.vm_network_ip_address}" : "ip=dhcp",
    var.vm_network_gw_adress != null ? "gw=${var.vm_network_gw_adress}" : ""
  ]
  
  ssh_public_key = file(var.vm_user_ssh_key_file)
}