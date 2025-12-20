## Terraform module for creating vm on ProxmoxVE

> [!NOTE]
> This Terraform module uses the **[Telmate](https://github.com/Telmate/terraform-provider-proxmox)** provider version **v3.0.2-rc05**.  
> Supported version of Proxmox not higher than **9.1.1**

> [!IMPORTANT]
>This terraform module uses pre-prepared virtual machine templates.
>If you use a Proxmox cluster, then virtual machine template should be located in the central storage or on each node of the cluster.

Terraform module for deploying QEMU virtual machines on Proxmox VE using the Telmate Terraform Provider for Proxmox.

This module supports:
- Clone from a template VM configured with cloud-init  
- Configure resources (CPU, memory) per VM  
- Configure system disk + additional data disks  
- One network interfaces per VM  
- Cloud-Init configuration via parameters or custom YAML  
- Outputs useful data (IP, MAC, node etc.)

#### Creating a virtual machine template using the console
```sh
qm create 999 --name Debina11-CloudInit
qm importdisk 999 /tmp/debian-12-generic-amd64.qcow2 local-zfs
qm set 999 --scsihw virtio-scsi-pci --virtio0 local-zfs:vm-999-disk-0
qm set 999 --net0 virtio,bridge=vmbr0
qm set 999 --ostype l26
qm set 999 --ide2 local-zfs:cloudinit
qm set 999 --boot c --bootdisk virtio0
qm set 999 --serial0 socket --vga serial0
qm set 999 --agent enabled=1
qm template 999
```

## Variables info
| Name           | Type     | Description                                                                                            |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------ |
| `node_name`    | `string` | Proxmox node to deploy VM(s) `"pve"` or `"pve,pve1,pve2"`                                              |
| `pool_name`    | `string` | Pool ID for VM(s) (optional)                                                                           |
| `vm_tags`      | `string` | VM tags as comma-separated list, e.g. `"tag1,tag2"`                                                    |
| `vm_count`     | `number` | Number of VMs to deploy                                                                                |
| `template_name`| `string` | Template VM name to clone                                                                              |
| `template_id`  | `number` | Template VM ID to clone                                                                                |
| `resources`    | `object` | VM hardware resources: `sockets`, `cores`, `cpu_type`, `memory`                                        |
| `disk`         | `object` | Disk configuration: `system_size`, `data_sizes`, `storage_name`, `format`                              |
| `network`      | `object` | Network configuration: , `domain_name`, `dns`                                                          |
| `cloud_init`   | `object` | Cloud-Init config: `ssh_username`, `ssh_password`, `ssh_user_key_file`, `cloudinit_file`, `os_upgrade` |

## Example of using the module
#### main.tf
```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc05"
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

  node_name     = "pve"
  pool_name     = "pool-example"
  template_name = "Debian12-CloudInit"
  vm_name       = "vm-example"
  vm_count      = 1
  vm_tags       = "example, vm"

  resources = {
    cpu_type = "x86-64-v2-AES"
    sockets  = 1
    cores    = 2
    memory   = 2
  }

  disk = {
    system_size  = 25
    data_sizes   = "10"
    storage_name = "local-zfs"
    format       = "raw"
  }

  network = {
    model       = "virtio"
    bridge_name = "vmbr0"
    vlan_id     = 100
    ip_address  = "xxx.xxx.xxx.xxx/24"
    gw_address  = "xxx.xxx.xxx.xxx"
    domain_name = "example.local.corp"
    dns         = "8.8.8.8, 1.1.1.1"
  }

  cloud_init = {
    ssh_username      = "vmuser"
    ssh_password      = "P@ssw0rd"
    ssh_user_key_file = "~/.ssh/id_rsa.pub"
    os_upgrade        = true
    cloudinit_file    = "local:snippets/custom-cloudinit.yaml"
  }

  OR

  cloud_init = {
    cloudinit_file    = "local:snippets/custom-cloudinit.yaml"
  }
}
```

#### output.tf
```sh
output "example_deploy_vm" {
  value = module.example_deploy_vm.vm_info
}

resource "local_file" "ansible_inventory_file" {
  content = templatefile("./ansible/inventory/hosts.tmpl", {
    ssh_username = module.example_deploy_vm.ssh_username
    vm_example   = module.example_deploy_vm.vm_info
  })

  filename = "./ansible/inventory/hosts"
}
```
##### Example Outputs
```
example_deploy_vm = {
  "vm-example" = {
    "domain_name" = "example.local.corp"
    "fqdn" = "vm-example.example.local.corp"
    "gateway" = "192.168.0.2"
    "ip" = "192.168.0.1"
    "macaddr" = "bc:24:11:08:e7:3e"
    "ssh_password" = "P@ssw0rd"
    "ssh_user" = "vmuser"
    "tags" = "example, vm"
  }
}
```

#### hosts.tmpl
```tmpl
[vm]
%{ for key, value in vm_example ~}
${value.fqdn} ansible_host=${value.ip}
%{ endfor ~}

[all:vars]
ansible_user=${ssh_username}
ansible_ssh_private_key_file="~/.ssh/id_rsa"
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_python_interpreter=/usr/bin/python3
```