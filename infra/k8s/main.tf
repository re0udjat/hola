# Setup OpenTofu provider
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  # Target Proxmox API endpoint (Required)
  pm_api_url = "https://192.168.65.10:8006/api2/json"

  # PVE uses self-signed certificates
  pm_tls_insecure = true
}

# Create VM Qemu resource
resource "proxmox_vm_qemu" "worker-nodes" {
  # General configuration
  name        = "worker-node-0"
  target_node = "pve"
  vmid        = 101

  # OS configuration
  qemu_os = "l26"

  # System configuration
  bios    = "ovmf"
  agent   = 0
  scsihw  = "virtio-scsi-pci"
  machine = "q35"

  # Memory configuration
  memory = 4096

  # Graphic configuration
  vga {
    type   = "qxl"
    memory = 16
  }

  # Disk configuration
  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/debian-12.11.0-amd64-netinst.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = "30G"
          storage = "vmdata"
          cache   = "none"
          discard = true
        }
      }
      scsi1 {
        disk {
          size     = "40G"
          storage  = "vmdata"
          cache    = "none"
          discard  = true
          iothread = true
        }
      }
    }
  }

  # EFI Disk configuration
  efidisk {
    efitype           = "4m"
    storage           = "vmdata"
    pre_enrolled_keys = true
  }

  # CPU configuration
  cpu {
    sockets = 1
    cores   = 2
    type    = "host"
  }

  # Network configuration
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = true
  }
}
