module "vm" {
  source  = "../modules/libvirt"
  num_vms = var.num_vms
}

resource "local_file" "nixos_vars" {
  content         = jsonencode(module.vm.vms)
  filename        = var.nixos_vars_file
  file_permission = "600"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "git add -f '${var.nixos_vars_file}'"
  }
}

output "bootstrap_password" {
  value = module.vm.bootstrap_password
}

output "bootstrap_user" {
  value = module.vm.bootstrap_user
}

output "num_vms" {
  value = var.num_vms
}

output "vms" {
  value = module.vm.vms
}
