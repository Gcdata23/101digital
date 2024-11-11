resource "aws_vpc_ipam" "vpc_ipam" {
  operating_regions {
    region_name = var.region
  }
}

resource "aws_vpc_ipam_pool" "vpc_ipam_pool" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.vpc_ipam.private_default_scope_id
  locale         = var.region
}

resource "aws_vpc_ipam_pool_cidr" "vpc_ipam_pool_cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.vpc_ipam_pool.id
  cidr         = var.vpc_cidr
}

resource "aws_vpc" "vpc" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.vpc_ipam_pool.id
  ipv4_netmask_length = var.vpc_ipv4_netmask_length
  enable_dns_support = true
  enable_dns_hostnames = true
  depends_on = [
    aws_vpc_ipam_pool_cidr.vpc_ipam_pool_cidr
  ]
}

locals {
  public_subnets = {
    "subnet-a" = {
      zone       = "us-west-2a"
      cidr_block = "10.0.1.0/24"
    }
    "subnet-b" = {
      zone       = "us-west-2b"
      cidr_block = "10.0.2.0/24"
    }
  }
}


resource "aws_subnet" "eks_cluster" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.vpc]
}

resource "aws_subnet" "eks_nodegroup" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.10.0/24"
#  map_public_ip_on_launch = true

  tags = {
    Name                              = "private-us-east-1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/test"      = "owned"
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_internet_gateway" "internetgw" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_subnet.eks_cluster]
}

resource "aws_eip" "natgw_eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = aws_subnet.eks_cluster["subnet-b"].id

  depends_on = [aws_subnet.eks_cluster]
}

resource "aws_route_table" "eks_cluster" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgw.id
  }
}

resource "aws_route_table_association" "eks_cluster" {
  for_each       = aws_subnet.eks_cluster
  subnet_id      = each.value.id
  route_table_id = aws_route_table.eks_cluster.id
}

resource "aws_route_table" "eks_nodegroup" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "eks_nodegroup" {
  subnet_id      = aws_subnet.eks_nodegroup.id
  route_table_id = aws_route_table.eks_nodegroup.id
}

locals {
  vpc_endpoint_service = {
    "eks-api" = {
      service_name = "com.amazonaws.${var.region}.eks"
    }
    "eks-auth" = {
      service_name = "com.amazonaws.${var.region}.eks-auth"
    }
    "ecr-api" = {
      service_name = "com.amazonaws.${var.region}.ecr.api"
    }
    "ecr-dkr" = {
      service_name = "com.amazonaws.${var.region}.ecr.dkr"
    }
    "ec2" = {
      service_name = "com.amazonaws.${var.region}.ec2"
    }
    "elasticloadbalancing" = {
      service_name = "com.amazonaws.${var.region}.elasticloadbalancing"
    }
    "logs" = {
      service_name = "com.amazonaws.${var.region}.logs"
    }
    "sts" = {
      service_name = "com.amazonaws.${var.region}.sts"
    }
  }
}
# Interface Endpoint for EKS API
resource "aws_vpc_endpoint" "eks_api" {
  for_each = local.vpc_endpoint_service
  vpc_id            = aws_vpc.vpc.id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.eks.id]
  subnet_ids        = [aws_subnet.eks_nodegroup.id]
  private_dns_enabled = true
}