# Declaramos que requiere un proveedor de proxmox y este ira a buscarlo en Github
terraform {
    required_providers {
        proxmox = {
            # Le decimos el source que sera que template quieres y su version
            source = "telmate/proxmox"
            version = "3.0.1-rc1"
        }
    }
}

provider "proxmox" {
    # Es la url a tu host
    pm_api_url = "https://Proxmox-ip:8006/api2/json"
    # Api token id es como el usuario
    pm_api_token_id = "test@pam!test"
    # Api token secret es el token que generaste 
    pm_api_token_secret = "api-key"
    
    pm_tls_insecure = true
}


resource "proxmox_vm_qemu" "test-ubuntu" {
    count = 1
    # Añade al nombre de la entidad un numero y lo aumenta
    name = "test-${count.index + 1}"

    # var.proxmox_host hace referencia a donde se crea y guarda la VM
    target_node = var.proxmox_host
    #var.template_name seria el nombre de la template
    clone = var.template_name

    # Config de la VM
    agent = 1
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = 2048
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"

    # Configuracion del disco
    disks {
        scsi {
            scsi0 {
                disk {
                    size = 10
                    storage = "local-lvm"
                    iothread = true
                }
            }
        }
    }

    # Configuracion de la tarjeta de red
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # No se para que sirve
    lifecycle {
        ignore_changes = [ 
            network,
        ]
    }

    # Asigna una IP a la VM y va añadiendo 1 al fina
    ipconfig0 = "ip=192.168.20.3${count.index + 1}/24,gw=192.168.20.1"

    ssh_user = var.ssh_user
}

