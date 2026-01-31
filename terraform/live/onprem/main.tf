# 1. 데이터센터 조회 (Create가 아니라 Read)
# 이미 만들어진 데이터센터 정보를 가져옴. 중첩가상화 때문에 딜레이가 생겨서 그런지 create는 되는데 이후 리소스 생성에 오류가 생기네.
data "vsphere_datacenter" "dc" {
  name = "Hybrid-Fin-DC"
}

# 데이터스토어 정보 가져오기 (이름: datastore1)
data "vsphere_datastore" "ds" {
  name          = "datastore1"  # vCenter에 보이는 데이터스토어 이름
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 2. 컴퓨트 클러스터 조회 (Create X, Read O)
data "vsphere_compute_cluster" "cluster" {
  name          = "Prod-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 3. 리소스 풀 생성. 이거 쓸려면 DRS 켜져있어야함. 그런데 지금 실습규모에서는 굳이 필요없음.
#resource "vsphere_resource_pool" "rp_service" {
#  name                    = "Service-Pool"
#  parent_resource_pool_id = vsphere_compute_cluster.cluster.resource_pool_id
#}

# 4. 네트워크 정보 가져오기 (Service 망)
data "vsphere_network" "service_net" {
  name          = "Service-Network" # ESXi에서 서비스망으로 쓰는 포트그룹 이름
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 5. DB Master VM 생성
module "db_master" {
  source = "../../modules/onprem/vm"

  name             = "db-master"
  template_name    = "Ubuntu-22.04-Template"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  network_id       = data.vsphere_network.service_net.id
  
  ip_address       = "172.16.20.11" # Service망 IP
  gateway          = "172.16.20.254" # VyOS Service Gateway

  datastore_id     = data.vsphere_datastore.ds.id
}

# 6. DB Slave VM 생성
module "db_slave" {
  source = "../../modules/onprem/vm"

  name             = "db-slave"
  template_name    = "Ubuntu-22.04-Template"
  datacenter_id    = data.vsphere_datacenter.dc.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  network_id       = data.vsphere_network.service_net.id
  
  ip_address       = "172.16.20.12"
  gateway          = "172.16.20.254"

  datastore_id     = data.vsphere_datastore.ds.id
}