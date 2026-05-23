variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Instance type must be t2.micro, t3.micro or t3.small."
  }
}

variable "key_name" {
  type = string
}

variable "allowed_ports" {
  type    = list(number)
  default = [22, 80]

  validation {
    condition     = alltrue([for port in var.allowed_ports : port > 0 && port <= 65535])
    error_message = "Ports must be between 1 and 65535."
  }
}

variable "name_prefix" {
  type = string
}
