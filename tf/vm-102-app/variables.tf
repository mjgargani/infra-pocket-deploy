variable "pm_api_url" {
  description = "URL da API do Proxmox"
}

variable "pm_user" {
  description = "Usuário da API do Proxmox"
}

variable "pm_password" {
  description = "Senha do usuário da API"
  sensitive   = true
}

variable "target_node" {
  description = "Nome do nó Proxmox"
}

variable "template_name" {
  description = "Nome do template com cloud-init"
}

variable "vm_id" {
  description = "ID da VM a ser criada"
}

variable "vm_name" {
  description = "Nome da VM"
}

variable "ip_address" {
  description = "Endereço IP da VM"
}

variable "ssh_key" {
  description = "Caminho para a chave pública SSH"
}