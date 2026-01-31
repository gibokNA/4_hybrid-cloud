data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = var.datacenter_id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.name
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id

  # 템플릿 스펙 그대로 사용
  num_cpus = data.vsphere_virtual_machine.template.num_cpus
  memory   = data.vsphere_virtual_machine.template.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = var.network_id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  # [핵심] 복제 후 OS 내부 설정 변경 (IP, Hostname 등)
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.name
        domain    = "hybrid.lab"
      }

      network_interface {
        ipv4_address = var.ip_address
        ipv4_netmask = 24
      }

      ipv4_gateway = var.gateway
      dns_server_list = ["172.16.10.254", "8.8.8.8"] # VyOS를 DNS로 지정
    }
  }
}