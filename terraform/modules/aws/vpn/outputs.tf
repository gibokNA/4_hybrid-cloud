output "vpn_connection_id" {
  value = aws_vpn_connection.main.id
}

# 터널 1 정보
output "tunnel1_address" {
  value = aws_vpn_connection.main.tunnel1_address
}
output "tunnel1_preshared_key" {
  value     = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive = true
}
output "tunnel1_bgp_inside_address" { # AWS측 내부 IP
  value = aws_vpn_connection.main.tunnel1_vgw_inside_address
}
output "tunnel1_bgp_customer_address" { # 우리측 내부 IP (VyOS에 설정할 IP)
  value = aws_vpn_connection.main.tunnel1_cgw_inside_address
}

# 터널 2 정보 (이중화용)
output "tunnel2_address" {
  value = aws_vpn_connection.main.tunnel2_address
}
output "tunnel2_preshared_key" {
  value     = aws_vpn_connection.main.tunnel2_preshared_key
  sensitive = true
}