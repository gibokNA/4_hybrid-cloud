variable "vsphere_user" {
  description = "vCenter Admin User"
  type        = string
  default     = "administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vCenter Admin Password"
  type        = string
  sensitive   = true  # 터미널 출력 시 가려짐
}

variable "vsphere_server" {
  description = "vCenter Server FQDN or IP"
  type        = string
  default     = "vcenter.hybrid.lab" 
}

# ESXi 호스트 정보 (클러스터에 추가하기 위해)
variable "esxi_hosts" {
  description = "List of ESXi hosts to add to cluster"
  type        = list(string)
  default     = ["esxi-1.hybrid.lab", "esxi-2.hybrid.lab"]
}