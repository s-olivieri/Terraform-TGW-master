resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.internet_subnet.id
  tags = {
    "Name" = "NatGateway"
  }
  #depends_on = aws_internet_gateway.internet_internet_gateway.id
}

output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}


