
# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "${var.env_code}-vpc"
  }
}

# ---------------------------------------------
# Subnet
# ---------------------------------------------
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = var.public_cidr[count.index]

  tags = {
    Name = "${var.env_code}-public0${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_cidr)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = var.private_cidr[count.index]

  tags = {
    Name = "${var.env_code}-private0${count.index}"
  }
}

# ---------------------------------------------
# Internet Gateway
# ---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env_code}-private-igw"
  }
}

resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# ---------------------------------------------
# Elastic IP
# ---------------------------------------------
resource "aws_eip" "ngw" {
  count = length(var.public_cidr)

  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.env_code}-eip-ngw-0${count.index}"
  }
}

# ---------------------------------------------
# NAT Gateway
# ---------------------------------------------
resource "aws_nat_gateway" "ngw" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.env_code}-ngw-0${count.index}"
  }
}

# ---------------------------------------------
# Route Table
# ---------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env_code}-public-rt-0"
  }
}

resource "aws_route_table_association" "public_rt" {
  count = length(var.public_cidr)

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "private_rt" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env_code}-private-rt-0${count.index}"
  }
}

resource "aws_route_table_association" "private_rt" {
  count = length(var.private_cidr)

  route_table_id = aws_route_table.private_rt[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

resource "aws_route" "public_rt_ngw" {
  count = length(var.private_cidr)

  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}
