variable "base_cidr_block" {
  description = "A /16 CIDR range definition, such as 10.0.0.0/16, that the VPC will use"
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  type = string
  description = "This defines the deployment region"
  default     = "us-east-1"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}


variable "availability_zones" {
  description = "A list of availability zones in which to create subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "internet_gw" {
  type        = string
  description = "Name of your internet gateway"
  default     = "main-altschool-igw"
}

variable "server_info" {
  type = object({
    image_id      = string
    instance_type = string
    key_name      = string
  })

  default = {
    image_id      = "ami-06878d265978313ca"
    instance_type = "t2.micro"
    key_name      = "altschool-1"
  }
}

variable "inbound_ports" {
  type    = list(number)
  default = [80, 443, 22]
}

variable "x" {
  type = number
  default = 0
}

variable "private_key_path" {
  default = "altschool-1.pem"
}

variable "domain_name" {
  default = "onyekachukwuejiofornweke.me"
}