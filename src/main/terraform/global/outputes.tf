output "vpc_id" {
  value = module.fithealth_vpc.vpc_id

}
output "subnet_id" {
  value = module.fithealth_subnet_module[*].subnet_id

}
output "key_name" {
  value = module.fithealth_key_module.key_name

}
output "private_ip" {
  value = module.fithealth_instance_module[*].private_ip
}
output "db_endpoint" {
  value = module.rds_db_fithealth_module.db_endpoint
}
output "instance_id" {
  value = module.fithealth_instance_module[*].instance_id

}
output "lbr_dns" {
  value = module.fithealth_elb_module.fithealth_dns

}
output "public_ip" {
  value = aws_instance.jmpboxinstance.public_ip

}
output "rds_address" {
  value = module.rds_db_fithealth_module.rds_address

}
