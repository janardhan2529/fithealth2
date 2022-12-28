terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "ap-south-1"
  profile = "default"
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
resource "null_resource" "copy" {
  connection {
    type        = "ssh"
    host        = aws_instance.jmpboxinstance.public_ip
    user        = "ubuntu"
    private_key = file("C:/Users/janar/.ssh/jana")

  }
  provisioner "file" {
    source      = "D:/infrastructure/fithealth_usecase/fithealth2/src/main/terraform/global/keys/jana"
    destination = "/home/ubuntu/.ssh/jana"
  }

  provisioner "file" {
    source      = "D:/infrastructure/fithealth_usecase/fithealth2/src/main/config/tomcat.service.conf"
    destination = "/tmp/tomcat.service"
  }
  provisioner "local-exec" {
    command = "sed -i 's/connect/${module.rds_db_fithealth_module.rds_address}/g' D:/infrastructure/fithealth_usecase/fithealth2/src/main/config/ansible/java-playbook.yml"
    

  }
  provisioner "local-exec" {
    command = "sed -i 's/connect/${module.rds_db_fithealth_module.db_endpoint}/g' D:/infrastructure/fithealth_usecase/fithealth2/src/main/resources/db.properties &&  mvn -f D:/infrastructure/fithealth_usecase/fithealth2/pom.xml clean verify"


  }
  provisioner "file" {
    source      = "D:/infrastructure/fithealth_usecase/fithealth2/src/main/db/db-schema.sql"
    destination = "/tmp/db-schema.sql"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 /home/ubuntu/.ssh/jana",
      "sudo apt update -y",
      "sudo apt install -y ansible",
      "sudo apt install -y mysql-client-8.0",
      "printf '%s\n%s' ${module.fithealth_instance_module[0].private_ip} ${module.fithealth_instance_module[1].private_ip} > /tmp/hosts"
    ]


  }



}
resource "null_resource" "ansiblerun" {
  triggers = null_resource.copy.triggers
  connection {
    type        = "ssh"
    host        = aws_instance.jmpboxinstance.public_ip
    user        = "ubuntu"
    private_key = file("C:/Users/janar/.ssh/jana")
  }
  provisioner "file" {
    source      = "D:/infrastructure/fithealth_usecase/fithealth2/src/main/config/ansible/java-playbook.yml"
    destination = "/tmp/java-playbook.yml"
  }
  provisioner "file" {
    source      = "D:/infrastructure/fithealth_usecase/fithealth2/target/fithealth2.war"
    destination = "/tmp/fithealth2.war"
  }
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --private-key ~/.ssh/jana -i /tmp/hosts /tmp/java-playbook.yml"

    ]

  }
  depends_on = [
    aws_instance.jmpboxinstance
  ]
}
module "fithealth_elb_module" {
  source     = "../modules/subnet/services/lbr/elb"
  vpc_id     = module.fithealth_vpc.vpc_id
  subnet_ids = [module.fithealth_subnet_module[4].subnet_id, module.fithealth_subnet_module[5].subnet_id]
  instances  = module.fithealth_instance_module[*].instance_id
}
