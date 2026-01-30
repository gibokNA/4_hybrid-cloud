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