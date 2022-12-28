
resource "aws_security_group" "fithealth2_securitygroup" {
    vpc_id = var.vpc_id
    ingress  {
      cidr_blocks = [ "172.10.0.0/16" ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
    } 
    ingress {
         cidr_blocks = [ "172.10.0.0/16" ]
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
    }
    egress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
     protocol = "-1"
      to_port = 0
    } 
  
}
resource "aws_instance" "fithealth2_instance" {
    subnet_id = var.subnet_ids
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.fithealth2_securitygroup.id]
    instance_type = "t2.micro"
    ami = "ami-07ffb2f4d65357b42"
    
  
}