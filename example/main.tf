terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://pve.example.com:8006/api2/json"
  pm_api_token_id     = "test_api@pve!terraform"
  pm_api_token_secret = "XXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  pm_tls_insecure     = true
  pm_debug            = true
}

module "example_deploy_vm" {
  source = "github.com/myplixa/terraform-pve-telmate"

  node_name      = "pve"
  pool_name      = "pool-example"
  template       = "Debian12-CloudInit"
  vm_name        = "vm-example"
  vm_count       = 1
  vm_tags        = "example, vm"
  vm_description = "Example VM created by Terraform"

  # Resurce configuration
  resources = {
    cpu_type = "x86-64-v2-AES"
    sockets  = 1
    cores    = 2
    memory   = 2
  }

  # Disk configuration
  disk = {
    system_size  = 25
    data_sizes   = "10"
    storage_name = "local-zfs"
    format       = "raw"
  }

  # Network configuration
  network = {
    model       = "virtio"
    bridge_name = "vmbr0"
    vlan_id     = 100
    ip_address  = "xxx.xxx.xxx.xxx/24"
    gw_address  = "xxx.xxx.xxx.xxx"
    domain_name = "example.local.corp"
    dns         = "8.8.8.8, 1.1.1.1"
  }

  # Cloud-Init configuration
  cloud_init = {
    os_upgrade        = true
    ssh_username      = "vmuser"
    ssh_password      = "P@ssw0rd"
    ssh_user_key_file = "~/.ssh/id_rsa.pub"
    # cloudinit_file    = "beckup:snippets/cloud-init.yaml"
  }

}

output "example_deploy_vm" {
  value = module.example_deploy_vm.vm_info
}

resource "local_file" "ansible_inventory_file" {
  content = templatefile("./ansible/inventory/hosts.tmpl", {
    vm_example   = module.example_deploy_vm.vm_info
  })

  filename = "./ansible/inventory/hosts"
}