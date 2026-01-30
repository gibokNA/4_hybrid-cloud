# 1. VPC 생성
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # EKS 및 RDS 사용 시 필수
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# 2. Public Subnets 생성 (Web Layer, Bastion, NAT GW)
resource "aws_subnet" "public" {
  count             = length(var.public_subnets) # 변수 개수만큼 반복 생성
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true # 인스턴스 생성 시 공인 IP 자동 할당

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1" # 나중에 EKS LoadBalancer가 식별하는 태그
  }
}

# 3. Private Subnets 생성 (App Layer, EKS Nodes)
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1" # EKS Internal LB 태그
  }
}

# 4. Internet Gateway (IGW) - 인터넷으로 나가는 문
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# 5. NAT Gateway - Private Subnet이 인터넷을 쓰기 위한 우회로
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # 첫 번째 Public Subnet에 배치

  tags = {
    Name = "${var.name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.this] # IGW가 먼저 있어야 함
}

# 6. Route Table (Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# 7. Route Table (Private)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.name}-private-rt"
  }
}

# 8. Route Table Association (서브넷과 라우팅 테이블 연결)
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}