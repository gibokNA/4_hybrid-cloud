variable "name" {}
variable "template_name" {}
variable "datacenter_id" {}
variable "resource_pool_id" {}
variable "network_id" {}
variable "ip_address" {}
variable "gateway" {}

variable "datastore_id" {
  description = "ID of the datastore to deploy the VM"
  type        = string
}