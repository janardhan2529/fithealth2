resource "aws_security_group" "fithealth2lbr_securitygroup" {
    vpc_id = var.vpc_id
    ingress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }
    egress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
     protocol = "-1"
      to_port = 0
    }
}
resource "aws_elb" "fithealth2elb" {
  name               = "fithealthlbd"
  security_groups = [ aws_security_group.fithealth2lbr_securitygroup.id ]
  subnets = var.subnet_ids
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check  {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/fithealth2/healthcheck"
    interval = 30
  }
   instances                   = var.instances
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "fithealthlodbalancer"
  }
}