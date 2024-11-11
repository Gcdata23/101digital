variable "region" {
  description = "Region"
  type        = string
}

variable "vpc_cidr" {
  description = "Address CIDR"
  type        = string
}

variable "vpc_ipv4_netmask_length" {
  description = "IPv4 Subnet Mask"
  type        = string
}

variable "eks_nodegroup" {
  description = <<-EOT
    Map of Subnet
    subnet_ids  = list(string) (Required) List of Subnet IDs
    instance_types  = list(string) (Required) List of Instance Type

    scaling_config = optional(object({
      max          = number
      min          = number
      desired_size = number
    }))
    capacity_type  = string Capacity Type
    update_config = optional(map(object({
      max_unavailable = optional(number)
      max_unavailable_percentage = optional(number)
    })))
    })))
  EOT

  type = map(object({
    extra_subnet_ids = optional(list(string))
    instance_types   = list(string)

    scaling_config = object({
      max_size     = number
      min_size     = number
      desired_size = number
    })
    capacity_type = string
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
    tags   = optional(map(string))
    labels = optional(map(string))
  }))
}