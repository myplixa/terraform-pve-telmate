resource "proxmox_pool" "pool" {
  comment = "Creation of a brand new pool for the VMs"
  count   = local.create_pool
  poolid  = var.pool_name
}

resource "proxmox_vm_qemu" "deploy_vm" {
  depends_on = [proxmox_pool.pool]

  for_each    = toset(local.vm_names)
  target_node = local.deploy_vm_to_nodes[each.key]

  description = var.vm_description
  tags        = join(",", local.vm_tags)
  pool        = var.pool_name

  name               = each.key
  os_type            = "cloud-init"
  clone              = var.template_name
  clone_id           = var.template_id
  full_clone         = true
  agent              = 1
  boot               = "cdn"
  scsihw             = "virtio-scsi-pci"
  bootdisk           = "virtio0"
  hotplug            = 0
  kvm                = true
  start_at_node_boot = true
  machine            = var.machine
  qemu_os            = var.qemu_os

  cpu {
    cores   = var.resources.cores
    sockets = var.resources.sockets
    type    = var.resources.cpu_type
  }

  memory  = var.resources.memory * 1024
  balloon = var.resources.memory * 1024

  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = var.disk.storage_name
  }

  disk {
    slot      = "virtio0"
    type      = "disk"
    size      = var.disk.system_size
    storage   = var.disk.storage_name
    format    = var.disk.format
    asyncio   = var.disk.asyncio
    replicate = var.disk.replicate
    cache     = var.disk.cache
    iothread  = var.disk.iothread
    discard   = var.disk.discard
  }

  dynamic "disk" {
    for_each = local.data_disks
    content {
      slot      = "virtio${disk.key + 1}"
      type      = "disk"
      size      = disk.value
      storage   = var.disk.storage_name
      format    = var.disk.format
      asyncio   = var.disk.asyncio
      replicate = var.disk.replicate
      cache     = var.disk.cache
      iothread  = var.disk.iothread
      discard   = var.disk.discard
    }
  }

  network {
    id        = 0
    model     = var.network.model
    firewall  = false
    link_down = false
    tag       = var.network.vlan_id
    bridge    = var.network.bridge_name
  }

  nameserver   = join(" ", local.network_dns)
  searchdomain = var.network.domain_name
  ipconfig0    = join(",", local.vm_network_config)

  # Cloud-init Config
  ciuser     = local.ssh_username
  cipassword = local.ssh_password
  sshkeys    = local.ssh_public_key
  cicustom   = local.cloudinit_file != null ? "user=${local.cloudinit_file}" : null
  ciupgrade  = local.os_upgrade
  skip_ipv6  = true
}