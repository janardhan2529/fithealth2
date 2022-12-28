
resource "aws_eip" "fithealth2_eip" {
  vpc = true

}
resource "aws_nat_gateway" "fithealth2ng" {
  subnet_id     = var.public_subnet_id
  allocation_id = aws_eip.fithealth2_eip.id

}
resource "aws_route_table" "fithealth2ngrt" {
  vpc_id = var.vpc_id
  route {
    gateway_id = aws_nat_gateway.fithealth2ng.id
    cidr_block = "0.0.0.0/0"

  }
}
resource "aws_route_table_association" "fithealth2_ngassociation" {
  count          = length(var.subnet_ids)
  route_table_id = aws_route_table.fithealth2ngrt.id
  subnet_id      = element(var.subnet_ids, count.index)

}
