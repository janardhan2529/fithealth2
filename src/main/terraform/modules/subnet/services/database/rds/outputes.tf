output "subnet_group_name" {
    value = aws_db_subnet_group.fithealth2dbsubnetgroup.id
  
}
output "db_endpoint" {
    value = aws_db_instance.fithealthdbinstance.endpoint
  
}
output "rds_address" {
    value = aws_db_instance.fithealthdbinstance.address
  
}