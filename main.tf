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

resource "aws_security_group" "allowssh" {

  name = "allowssh"
  vpc_id = aws_vpc.mo_vpc.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "privateshh" {
  name = "allow_ssh_private"
  vpc_id = aws_vpc.mo_vpc.id

  ingress {
    description = "allow ssh from only from public subnet ec2"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
}


resource "aws_instance" "publicec2" {
  ami = var.ami
  instance_type = var.instancetype
  key_name = var.key
  subnet_id = aws_subnet.public-subnet.id
  associate_public_ip_address = true 
  vpc_security_group_ids = [aws_security_group.allowssh.id]
  
  tags = {
    "Name" = "publicec2"
  }
}
resource "aws_instance" "privateec2" {
  ami = var.ami
  instance_type = var.instancetype
  key_name = var.key
  subnet_id = aws_subnet.private-subnet.id
  associate_public_ip_address = true 
  vpc_security_group_ids = [aws_security_group.privateshh.id]

  tags = {
    Name = "privateec2"
  }
}