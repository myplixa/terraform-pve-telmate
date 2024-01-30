resource "proxmox_pool" "create_pool" {
  comment = "Creation of a brand new pool for the VMs"
  poolid  = local.pool_name
}

resource "proxmox_vm_qemu" "deploy_vm" {
  target_node = element(local.node_name, count.index)
  desc        = local.description_vm
  tags        = join(",", local.tags_vm)
  pool        = proxmox_pool.create_pool.poolid
  count       = local.count_vm

  name       = "${local.vm_name}-${count.index}"
  os_type    = "cloud-init"
  clone      = local.vm_clone_id
  full_clone = true
  agent      = 1
  boot       = "c"
  scsihw     = "virtio-scsi-pci"
  bootdisk   = "virtio0"
  hotplug    = 0
  oncreate   = true
  onboot     = true
  
  qemu_os    = "l26"
  cpu        = local.vm_cpu_type
  cores      = local.vm_cores
  memory     = local.vm_memory

  # Network interface configuration
  network {
    model     = "virtio"
    firewall  = false
    link_down = false
    tag       = local.vm_network_vlan_id
    bridge    = local.vm_newtwork_bridge_name
  }

  # Disk pool creation
  dynamic "disk" {
    for_each = { for index, val in local.vm_disk_sizes : tostring(index) => val }
    content {
      storage  = local.vm_storage_name
      size     = disk.value
      type     = "virtio"
      iothread = 1
      aio      = "native"
    }
  }

  # Cloud-init Config
  ciuser     = local.vm_user_name
  cipassword = local.vm_user_password

  nameserver   = local.vm_dns
  searchdomain = local.vm_search_domain

  ipconfig0 = join(",", compact(local.vm_network_config))
  sshkeys   = local.ssh_public_key
}