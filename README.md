## Terraform module for creating vm on ProxmoxVE

> This Terraform module uses the **[Telmate](https://github.com/Telmate/terraform-provider-proxmox)** provider version **v2.9.14**.  
> Supported version of Proxmox not higher than **8.0.3**

## 
```sh
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">= 2.9.14"
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

  node_name = ["pve"]
  pool_name = "pool-example"
  count_vm  = 3
  tags_vm   = ["example", "vm"]

  vm_name         = "vm-example"
  vm_clone_id     = "Debian12-CloudInit"
  vm_cpu_type     = "host"
  vm_cores        = 4
  vm_memory       = 8192
  vm_disk_sizes   = ["20G"]
  vm_storage_name = "local-zfs"

  vm_newtwork_bridge_name = "vmbr0"

  # Cloud-Init Info
  vm_user_name          = "user"
  vm_user_password      = "P@ssw0rd"
  vm_user_ssh_key_file  = "~/.ssh/id_rsa.pub"

  vm_search_domain      = "example.local.corp"
  vm_dns                = ["8.8.8.8", "1.1.1.1"]

  #These two parameters can be commented out, and then the network parameters will be set to "dhcp"
  vm_network_ip_address = "xxx.xxx.xxx.xxx/24"
  vm_network_gw_adress  = "xxx.xxx.xxx.xxx"
}
```