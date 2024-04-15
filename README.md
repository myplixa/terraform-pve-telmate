## Terraform module for creating vm on ProxmoxVE

> [!NOTE]
> This Terraform module uses the **[Telmate](https://github.com/Telmate/terraform-provider-proxmox)** provider version **v2.9.14**.  
> Supported version of Proxmox not higher than **8.0.3**

## Variables info
#### Global variables
| Name | Type | Default |
| ---- | ---- | ------- |
| node_name | list(string) | ["pve"] or ["pve","pve1","pve2"] |
| pool_name | string | null |
| tags_vm | list(string) | [""] or ["test","prod"] |
| description_vm | string | null |
| count_vm | number | 1 |
| vm_name | string | "node" |
| vm_clone_id | string | null |
| vm_cpu_type | string | "host" |
| vm_cores | number | 2 |
| vm_memory | number | 4096 |
| vm_disk_sizes | list(string) | ["10G"] or ["10G","50G"] |
| vm_storage_name | string | "local-zfs" |
| vm_newtwork_bridge_name | string | "vmbr0" |
| vm_network_vlan_id | number | null |

#### Cloud-Init variables
| Name | Type | Default |
| ---- | ---- | ------- |
| vm_user_name | string | null |
| vm_user_password | string | null |
| vm_search_domain | string | null |
| vm_dns | list(string) | null or ["8.8.8.8","1.1.1.1"] |
| vm_network_ip_address | string | null |
| vm_network_gw_adress | string | null |
| vm_user_ssh_key_file | string | null |

## Example of using the module
#### main.tf
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

#### output.tf
```sh
output "example_deploy_vm" {
  value = module.example_deploy_vm.vm_info
}

resource "local_file" "ansible_inventory_file" {
  content = templatefile("./ansible/inventory/hosts.tmpl", {
    
    vm_user = var.vm_user_name
    vm_domain = var.vm_domain_name

    vm_example = module.example_deploy_vm.vm_info
  })

  filename = "./ansible/inventory/hosts"
}
```

#### hosts.tmpl
```tmpl
[vm]
%{for key, value in vm_example ~}
${key}.${vm_domain} ansible_host=${value}
%{endfor ~}

[all:vars]
ansible_user="${vm_user}"
ansible_ssh_private_key_file="~/.ssh/id_rsa"
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```