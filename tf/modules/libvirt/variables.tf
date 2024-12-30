variable "bootstrap_password" {
  type        = string
  description = "Password for the nixos-anywhere bootstrapping process"
  default     = "some-password"
}

variable "cpu" {
  type        = number
  description = "Number of CPUs"
  default     = 1
}

variable "disk_size_data" {
  type        = number
  description = "Size of data disk in bytes"
  default     = 10737418240 # 10 GiB
}

variable "disk_size_system" {
  type        = number
  description = "Size of system disk in bytes"
  default     = 10737418240 # 10 GiB
}

variable "memory" {
  type        = number
  description = "Memory size in MiB"
  default     = 1024
}

variable "num_vms" {
  type        = number
  description = "Number of VMs to create"
  default     = 3
}
