provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# 모듈 호출 (Call the Module)
module "vpc" {
  source = "../../modules/aws/vpc" # 모듈 위치 지정

  name            = "hybrid-fin"
  vpc_cidr        = "10.0.0.0/16"
  
  # 가용영역 (AZ) 분산
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  
  # Subnet 설계 반영
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
}

# VPN 모듈 추가
module "vpn" {
  source = "../../modules/aws/vpn"

  name        = "hybrid-fin"
  vpc_id      = module.vpc.vpc_id
  
  public_route_table_id  = module.vpc.public_route_table_id
  private_route_table_id = module.vpc.private_route_table_id

  customer_asn = 65000  # 온프레미스 ASN
  customer_ip  = "1.224.39.56" # 내 집 공유기 ip 주소
}