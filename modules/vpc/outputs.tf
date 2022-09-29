output movpcid {
    value = aws_vpc.mo_vpc.id
}

output "pubsubnetid" {
  value = aws_subnet.public-subnet.id
}

output "privsubnetid" {
  value = aws_subnet.private-subnet.id
}