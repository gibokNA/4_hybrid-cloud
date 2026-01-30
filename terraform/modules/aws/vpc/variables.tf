variable "name" { description = "Project Name Prefix" }
variable "vpc_cidr" { description = "VPC CIDR Block" }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }