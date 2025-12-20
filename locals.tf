#------------------------------------------------------------------------------
# GENERAL GROUPING / TAGS
#------------------------------------------------------------------------------
locals {
  create_pool = var.pool_name != null ? 1 : 0

  vm_tags = (var.vm_tags == null ? [] :
    compact([
      for t in split(",", var.vm_tags) : trimspace(t)
    ])
  )
}

#------------------------------------------------------------------------------
#  NODE LIST
#------------------------------------------------------------------------------
locals { // 
  node_names = compact([for n in split(",", var.node_name) : trimspace(n)])
}

#------------------------------------------------------------------------------
#  VM NAMING / NODE DISTRIBUTION
#------------------------------------------------------------------------------
locals {
  vm_names = var.vm_count == 1 ? [var.vm_name] : [for i in range(var.vm_count) : "${var.vm_name}-${i + 1}"]

  deploy_vm_to_nodes = {
    for name in local.vm_names : name => element(
      local.node_names,
      can(regex("[0-9]+$", name))
      ? (tonumber(regex("[0-9]+$", name)) - 1) % length(local.node_names)
      : 0
    )
  }
}

#------------------------------------------------------------------------------
#  DISK CONFIGURATION
#------------------------------------------------------------------------------
locals {
  data_disks       = compact([for d in split(",", lookup(var.disk, "data_sizes", "")) : trimspace(d)])
  system_disk_size = lookup(var.disk, "system_size", 10)
  storage_name     = lookup(var.disk, "storage_name", "local-zfs")
  disk_format      = lookup(var.disk, "format", "raw")
}

#------------------------------------------------------------------------------
#  NETWORK CONFIGURATION
#------------------------------------------------------------------------------
locals {
  network_dns = (var.network.dns != null ?
    [for d in split(",", var.network.dns) : trimspace(d)] : []
  )

  vm_network_config = compact([
    var.network.ip_address != null ? "ip=${var.network.ip_address}" : "ip=dhcp",
    var.network.gw_address != null ? "gw=${var.network.gw_address}" : ""
  ])
}

#------------------------------------------------------------------------------
#  CLOUD-INIT CONFIGURATION
#------------------------------------------------------------------------------
locals {
  cloudinit_file    = try(var.cloud_init.cloudinit_file, null)
  ssh_username      = try(var.cloud_init.ssh_username, null)
  ssh_password      = try(var.cloud_init.ssh_password, null)
  ssh_user_key_file = try(var.cloud_init.ssh_user_key_file, null)
  os_upgrade        = try(var.cloud_init.os_upgrade, false)

  ssh_public_key = (
    local.ssh_user_key_file == null ? null :
    fileexists(local.ssh_user_key_file)
    ? file(local.ssh_user_key_file)
    : local.ssh_user_key_file
  )
}
