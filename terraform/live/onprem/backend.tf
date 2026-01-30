# backend.tf
terraform {
  backend "s3" {
    bucket         = "4-hybrid-cloud-tfstate-1234" 
    key            = "on-premise/terraform.tfstate" # 상태 파일 저장 경로
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "4-hybrid-cloud-on-premise-tflock"
  }
}