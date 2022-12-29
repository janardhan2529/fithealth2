terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "ap-south-1"
}
module "fithealth_vpc" {
  source = "../modules/vpc"

}
module "fithealth_subnet_module" {
  count        = length(var.subnet_cidrs)
  source       = "../modules/subnet"
  vpc_id       = module.fithealth_vpc.vpc_id
  subnet_cidrs = element(var.subnet_cidrs, count.index)
  subnet_name  = "fithealth2_sb ${count.index}"
  zone         = element(var.zone, count.index)

}
module "fithealth_ig_module" {
  vpc_id     = module.fithealth_vpc.vpc_id
  source     = "../modules/gateway/ig"
  subnet_ids = [module.fithealth_subnet_module[4].subnet_id, module.fithealth_subnet_module[5].subnet_id]

}
module "fithealthng_module" {
  source           = "../modules/gateway/ng"
  vpc_id           = module.fithealth_vpc.vpc_id
  subnet_ids       = [module.fithealth_subnet_module[0].subnet_id, module.fithealth_subnet_module[1].subnet_id]
  public_subnet_id = module.fithealth_subnet_module[4].subnet_id

}
module "rds_db_fithealth_module" {
  source     = "../modules/subnet/services/database/rds"
  vpc_id     = module.fithealth_vpc.vpc_id
  subnet_ids = [module.fithealth_subnet_module[2].subnet_id, module.fithealth_subnet_module[3].subnet_id]

}
module "fithealth_key_module" {
  source     = "../modules/subnet/services/compute/keypair"
  public_key = var.public_key

}
module "fithealth_instance_module" {
  count      = 2
  source     = "../modules/subnet/services/compute/ec2"
  vpc_id     = module.fithealth_vpc.vpc_id
  subnet_ids = module.fithealth_subnet_module[count.index].subnet_id
  key_name   = module.fithealth_key_module.key_name
  depends_on = [
    module.fithealthng_module,
    module.rds_db_fithealth_module
  ]

}
resource "aws_security_group" "jmpboxsecuritygroup" {
  vpc_id = module.fithealth_vpc.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}
resource "aws_instance" "jmpboxinstance" {
  subnet_id                   = module.fithealth_subnet_module[4].subnet_id
  vpc_security_group_ids      = [aws_security_group.jmpboxsecuritygroup.id]
  instance_type               = "t2.micro"
  ami                         = "ami-07ffb2f4d65357b42"
  key_name                    = module.fithealth_key_module.key_name
  associate_public_ip_address = true

}


module "fithealth_elb_module" {
  source     = "../modules/subnet/services/lbr/elb"
  vpc_id     = module.fithealth_vpc.vpc_id
  subnet_ids = [module.fithealth_subnet_module[4].subnet_id, module.fithealth_subnet_module[5].subnet_id]
  instances  = module.fithealth_instance_module[*].instance_id
}
   
    
