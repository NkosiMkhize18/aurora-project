output "vpc_id" {
  description = "ID of the Aurora VPC."
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Availability zones used by the private subnets."
  value       = aws_subnet.private[*].availability_zone
}
