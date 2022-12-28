
resource "aws_subnet" "fithealthsb" {
  vpc_id            = var.vpc_id
  availability_zone = var.zone
  cidr_block        = var.subnet_cidrs
  tags = {
    subnet_name = var.subnet_name
  }
}
