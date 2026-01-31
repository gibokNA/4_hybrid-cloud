# 1. Customer Gateway (CGW) 생성
# 온프레미스(우리 집) 라우터 정보를 AWS에 등록
resource "aws_customer_gateway" "main" {
  bgp_asn    = var.customer_asn # 온프레미스 BGP 번호 (65000)
  ip_address = var.customer_ip  # 우리 집 공인 IP
  type       = "ipsec.1"

  tags = {
    Name = "${var.name}-cgw"
  }
}

# 2. Virtual Private Gateway (VGW) 생성
# AWS 측 VPN 관문 생성
resource "aws_vpn_gateway" "main" {
  vpc_id          = var.vpc_id
  amazon_side_asn = 64512 # AWS 기본 BGP 번호

  tags = {
    Name = "${var.name}-vgw"
  }
}

# 3. VGW를 VPC에 부착
resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.main.id
}

# 4. VPN Connection 생성 (터널링)
# CGW와 VGW를 연결하고 터널 2개를 생성
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = false # BGP를 쓸 것이므로 False (Dynamic Routing)

  tags = {
    Name = "${var.name}-vpn-connection"
  }
}

# 5. Route Propagation (경로 전파) 활성화
# BGP로 배운 온프레미스 경로(172.16.x.x)를 AWS 라우팅 테이블에 자동으로 등록
resource "aws_vpn_gateway_route_propagation" "public" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = var.public_route_table_id
}

resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = var.private_route_table_id
}