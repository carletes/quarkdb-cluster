variable "nixos_vars_file" {
  type        = string
  description = "File to write NixOS configuration variables to"
}

variable "num_vms" {
  type    = number
  default = 3
}
