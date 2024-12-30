resource "libvirt_volume" "debian_cloudimage" {
  name   = "debian_cloudimage"
  source = "https://cdimage.debian.org/images/cloud/bookworm/20241201-1948/debian-12-genericcloud-amd64-20241201-1948.qcow2"
}

resource "libvirt_volume" "quarkdb_system" {
  count          = var.num_vms
  name           = format("quarkdb-system-%d", count.index)
  size           = var.disk_size_system
  base_volume_id = libvirt_volume.debian_cloudimage.id
}

resource "libvirt_volume" "quarkdb_data" {
  count = var.num_vms
  name  = format("quarkdb-data-%d", count.index)
  size  = var.disk_size_data
}

resource "libvirt_cloudinit_disk" "quarkdb" {
  count          = var.num_vms
  name           = format("quarkdb-cloud-init-%d", count.index)
  user_data      = templatefile("${path.module}/cloud-init/user-data", { bootstrap_password = var.bootstrap_password })
  meta_data      = templatefile("${path.module}/cloud-init/meta-data", {})
  network_config = templatefile("${path.module}/cloud-init/network-config", {})
}

resource "libvirt_domain" "quarkdb" {
  count  = var.num_vms
  name   = format("quarkdb-%d", count.index)
  memory = var.memory
  vcpu   = var.cpu

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.quarkdb_system[count.index].id
  }

  disk {
    volume_id = libvirt_volume.quarkdb_data[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.quarkdb[count.index].id

  network_interface {
    network_name   = "default"
    hostname       = format("quarkdb-%d", count.index)
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

output "bootstrap_user" {
  value = "debian"
}

output "bootstrap_password" {
  value = var.bootstrap_password
}

output "ipv4_addresses" {
  value = [for vm in libvirt_domain.quarkdb : vm.network_interface.0.addresses.0]
}
