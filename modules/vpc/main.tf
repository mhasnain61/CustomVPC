terraform {
  required_version = ">=1.2.8"
}

resource "aws_vpc" "mo_vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.mo_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name= "public-subnet"
  } 
}

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.mo_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.mo_vpc.id

  tags = {
    Name = "newigw"
  }
  
}

resource "aws_route_table" "alphapublicroute" {
  vpc_id = aws_vpc.mo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "publicroute"
  }
}

resource "aws_route_table" "alphaprivateroute" {
  vpc_id = aws_vpc.mo_vpc.id
  route {
    cidr_block = "10.0.1.0/24"
    nat_gateway_id = aws_nat_gateway.alphangw.id
  }

  tags = {
    Name = "privateroute"
  }
  
}

resource "aws_route_table_association" "publicassociation" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.alphapublicroute.id 
}

resource "aws_route_table_association" "privateassociation" {

  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.alphaprivateroute.id 
}

resource "aws_eip" "ngwip" {
  vpc = true
}

resource "aws_nat_gateway" "alphangw" {
  allocation_id = aws_eip.ngwip.id 
  connectivity_type = "public"
  subnet_id = aws_subnet.public-subnet.id
  
}