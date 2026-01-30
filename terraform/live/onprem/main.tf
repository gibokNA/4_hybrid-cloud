# 1. 데이터센터 조회 (Create가 아니라 Read)
# 이미 만들어진 데이터센터 정보를 가져옴. 중첩가상화 때문에 딜레이가 생겨서 그런지 create는 되는데 이후 리소스 생성에 오류가 생기네.
data "vsphere_datacenter" "dc" {
  name = "Hybrid-Fin-DC"
}

# 2. 컴퓨트 클러스터 생성
resource "vsphere_compute_cluster" "cluster" {
  name            = "Prod-Cluster"
  
  # resource.dc.id 가 아니라 data.dc.id 를 참조.
  datacenter_id   = data.vsphere_datacenter.dc.id
  
  ha_enabled = true
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
}

# 3. 리소스 풀 생성
resource "vsphere_resource_pool" "rp_service" {
  name                    = "Service-Pool"
  parent_resource_pool_id = vsphere_compute_cluster.cluster.resource_pool_id
}