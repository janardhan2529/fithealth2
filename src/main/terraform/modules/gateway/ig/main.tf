
resource "aws_internet_gateway" "fithealth2ig" {
  vpc_id = var.vpc_id
  tags = {
    "name" = "fithealth2ig"
  }
}
resource "aws_route_table" "fithealth2rt" {
  vpc_id = var.vpc_id
  route {
    gateway_id = aws_internet_gateway.fithealth2ig.id
    cidr_block = "0.0.0.0/0"

  }
}
resource "aws_route_table_association" "fithealth2_association" {
  count          = length(var.subnet_ids)
  route_table_id = aws_route_table.fithealth2rt.id
  subnet_id      = element(var.subnet_ids, count.index)

}
