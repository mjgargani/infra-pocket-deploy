# Provisionamento da VM 102 (app) – Ubuntu Server

Este módulo Terraform provisiona uma VM baseada em um template Ubuntu Server com Cloud-Init no Proxmox VE.

## Pré-requisitos

- Template `ubuntu-template` com Cloud-Init no Proxmox
- Usuário `terraform@pve` com permissão via API
- SSH key pública configurada no host

## Uso

```bash
cd terraform/vm-102-app
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

> 🔐 Nunca commite `terraform.tfvars` com senhas reais.