variable "name" { description = "Resource Name Prefix" }
variable "vpc_id" { description = "AWS VPC ID" }
variable "customer_ip" { description = "On-Premise Public IP" }
variable "customer_asn" { description = "On-Premise BGP ASN" }
variable "public_route_table_id" { description = "Public RT ID for Propagation" }
variable "private_route_table_id" { description = "Private RT ID for Propagation" }