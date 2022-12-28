
resource "aws_db_subnet_group" "fithealth2dbsubnetgroup" {
    subnet_ids = var.subnet_ids
}
resource "aws_security_group" "fithealth2dbsecurity_group" {
    vpc_id = var.vpc_id
        ingress  {
      cidr_blocks = [ "172.10.0.0/16" ]
      from_port = 3306
      protocol = "tcp"
      to_port = 3306
    } 
    egress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
     protocol = "-1"
      to_port = 0
    }   
}
resource "aws_db_instance" "fithealthdbinstance" {
 vpc_security_group_ids = [aws_security_group.fithealth2dbsecurity_group.id]
  allocated_storage    = 10
  db_name              = "fithealthdb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "root"
  password             = "jana1234"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.fithealth2dbsubnetgroup.id
  
}
