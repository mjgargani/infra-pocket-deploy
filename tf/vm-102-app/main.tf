provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "app_vm" {
  name        = var.vm_name
  target_node = var.target_node
  vmid        = var.vm_id
  clone       = var.template_name

  cores       = 4
  memory      = 4096

  os_type     = "cloud-init"
  sshkeys     = file(var.ssh_key)

  ipconfig0   = "ip=${var.ip_address}/23,gw=10.0.0.1"
  ciuser      = "ubuntu"
}