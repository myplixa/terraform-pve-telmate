terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "~>2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url          = ""
  pm_api_token_id     = ""
  pm_api_token_secret = ""
  pm_tls_insecure     = true
  pm_debug            = true
}

module "deploy-test" {
  source = "../"

  node_name = ["pve1"]
  pool_name = "test"
  tags_vm = ["test", "servise"]
  description_vm = "Deploy vm from terraform"
  count_vm = "2"

  vm_name = "test-1"
  vm_clone_id = "Debian-12-Cloud"
}