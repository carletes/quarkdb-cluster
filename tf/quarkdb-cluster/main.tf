module "vm" {
  source  = "../modules/libvirt"
  num_vms = var.num_vms
}

output "bootstrap_password" {
  value = module.vm.bootstrap_password
}

output "bootstrap_user" {
  value = module.vm.bootstrap_user
}

output "ipv4_addresses" {
  value = module.vm.ipv4_addresses
}

output "num_vms" {
  value = var.num_vms
}
