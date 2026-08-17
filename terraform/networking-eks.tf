# ==========================================
# EKS NETWORKING
# ==========================================

# ------------------------------------------
# Second Public Subnet
# ------------------------------------------

resource "aws_subnet" "eks_public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-2"
  }
}

# ------------------------------------------
# Private Subnet 1
# ------------------------------------------

resource "aws_subnet" "eks_private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "eks-private-subnet-1"
  }
}

# ------------------------------------------
# Private Subnet 2
# ------------------------------------------

resource "aws_subnet" "eks_private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "eks-private-subnet-2"
  }
}

# ------------------------------------------
# Elastic IP for NAT Gateway
# ------------------------------------------

resource "aws_eip" "eks_nat" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

# ------------------------------------------
# NAT Gateway
# ------------------------------------------

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "eks-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.igw
  ]
}

# ------------------------------------------
# Private Route Table
# ------------------------------------------

resource "aws_route_table" "eks_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

# ------------------------------------------
# Private Subnet 1 Association
# ------------------------------------------

resource "aws_route_table_association" "eks_private_1" {
  subnet_id      = aws_subnet.eks_private_1.id
  route_table_id = aws_route_table.eks_private.id
}

# ------------------------------------------
# Private Subnet 2 Association
# ------------------------------------------

resource "aws_route_table_association" "eks_private_2" {
  subnet_id      = aws_subnet.eks_private_2.id
  route_table_id = aws_route_table.eks_private.id
}

# ------------------------------------------
# Public Subnet 2 Association
# ------------------------------------------

resource "aws_route_table_association" "eks_public_2" {
  subnet_id      = aws_subnet.eks_public_2.id
  route_table_id = aws_route_table.public.id
}