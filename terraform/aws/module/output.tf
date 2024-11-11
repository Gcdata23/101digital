output "region" {
  value = var.region
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_name" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}


output "eks_cluster_autoscaler_role_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}

output "aws_eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}

output "aws-load-balancer-controller_role_arn" {
  value = aws_iam_role.aws-load-balancer-controller.arn
}

output "aws_security_group_nlb_id" {
  value = aws_security_group.eks-nlb.id
}

#output "aws_cloudwatch_log_group_arn" {
#  value = aws_cloudwatch_log_group.test.arn
#}
output "eks_cloudwatch_role_arn" {
  value = aws_iam_role.cloudwatch.arn
}
