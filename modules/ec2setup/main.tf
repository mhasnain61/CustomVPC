resource "aws_security_group" "allowssh" {

  name = "allowssh"
  vpc_id = var.alphaid

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "privateshh" {
  name = "allow_ssh_private"
  vpc_id = var.alphaid

  ingress {
    description = "allow ssh from only from public subnet ec2"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "publicec2" {
  ami = var.ami
  instance_type = var.instancetype
  key_name = var.key
  subnet_id = var.pubid
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
  subnet_id = var.privid
  associate_public_ip_address = true 
  vpc_security_group_ids = [aws_security_group.privateshh.id]

  tags = {
    Name = "privateec2"
  }
}