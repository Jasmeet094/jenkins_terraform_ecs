output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_ip" {
  value       = aws_eip.nat_gw_eip.public_ip
  description = "The public IP of the NAT Gateway"
}