terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_endpoint
  api_token = var.pve_api_token
  insecure  = true # certificat auto-signe du lab, jamais en production
}


resource "proxmox_virtual_environment_container" "web" {
  count = var.nb_web # <= toute la magie est ici

  node_name    = var.pve_node
  vm_id        = var.ctid_web_base + count.index # <= a vous
  pool_id      = var.pool
  unprivileged = true

  features {
    nesting = true
  }

  initialization {
    hostname = format("serveur-web-%02d", count.index + 1) # <= a vous : srv-web-01, srv-web-02, ...

    ip_config {
      ipv4 {
        address = "${cidrhost(var.reseau, var.hote_web_base + count.index)}/16" # <= a vous, avec le masque /16
        gateway = var.passerelle
      }
    }

    user_account {
      keys = [trimspace(file(var.cle_publique))]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = var.stockage
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = var.pont
  }

  operating_system {
    template_file_id = var.template
    type             = "debian"
  }
}

resource "proxmox_virtual_environment_container" "proxy" {


  node_name    = var.pve_node
  vm_id        = var.ctid_proxy # <= a vous
  pool_id      = var.pool
  unprivileged = true

  features {
    nesting = true
  }

  initialization {
    hostname = "srv-proxy" # <= a vous : srv-web-01, srv-web-02, ...

    ip_config {
      ipv4 {
        address = "${cidrhost(var.reseau, var.hote_proxy)}/16" # <= a vous, avec le masque /16
        gateway = var.passerelle
      }
    }

    user_account {
      keys = [trimspace(file(var.cle_publique))]
    }
  }
  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = var.stockage
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = var.pont
  }

  operating_system {
    template_file_id = var.template
    type             = "debian"
  }

}