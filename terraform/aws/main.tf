terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_ket
}

provider "helm" {
  registry_config_path = "repositories.yaml"
  kubernetes {
    config_path = "~/.kube/config"
  }

  # localhost registry with password protection
  #  registry {
  #    url = "oci://localhost:5000"
  #    username = "username"
  #    password = "password"
  #  }

  #  # private registry
  #  registry {
  #    url = "oci://private.registry"
  #    username = "username"
  #    password = "password"
  #  }
}

module "max_weather" {
  source                  = "./module"
  region                  = "us-west-2"
  vpc_cidr                = "10.0.0.0/16"
  vpc_ipv4_netmask_length = "16"
  eks_nodegroup = {
    "app" = {
      instance_types = ["t3.small"]
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 0
      }
      capacity_type = "ON_DEMAND"
      update_config = {
        max_unavailable = 1
      }
      labels = {
        node = "app"
      }
    }
    "jenkins" = {
      instance_types = ["t3.small"]
      scaling_config = {
        desired_size = 1
        max_size     = 3
        min_size     = 0
      }
      capacity_type = "ON_DEMAND"
      update_config = {
        max_unavailable = 1
      }
      labels = {
        node = "jenkins"
      }
    }
  }
}

#source https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler
resource "helm_release" "autoscaler" {
  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  namespace  = "kube-system"
  chart      = "cluster-autoscaler"
  version    = "9.43.2"
  set {
    name  = "nodeSelector.node"
    value = "app"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = "test"
  }
  set {
    name  = "awsRegion"
    value = module.max_weather.region
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.max_weather.eks_cluster_autoscaler_role_arn
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  set {
    name  = "nodeSelector.node"
    value = "app"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "clusterName"
    value = module.max_weather.aws_eks_cluster_name
  }
  #  set {
  #    name  = "serviceAccount.create"
  #    value = "false"
  #  }
  #  set {
  #    name  = "serviceAccount.name"
  #    value = "aws-load-balancer-controller"
  #  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.max_weather.aws-load-balancer-controller_role_arn
  }
  set {
    name  = "region"
    value = module.max_weather.region
  }
  set {
    name  = "vpcId"
    value = module.max_weather.vpc_id
  }
  #  set {
  #    name  = "controller.service.externalTrafficPolicy"
  #    value = "Local"
  #  }
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
  #    value = "true"
  #  }
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
  #    value = "nlb"
  #  }
  #
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
  #    value = "nlb"
  #  }
  #
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
  #    value = "true"
  #  }
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-manage-backend-security-group-rules"
  #    value = "true"
  #  }
  #  set {
  #    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
  #    value = "sg-0a243e4f7808d0fda"
  #  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  set {
    name  = "nodeSelector.node"
    value = "app"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-manage-backend-security-group-rules"
    value = "true"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
    value = module.max_weather.aws_security_group_nlb_id
  }
  depends_on = [module.max_weather]
}

# Log To CloudWatch
resource "helm_release" "fluent-bit" {
  name       = "fluent-bit"
  namespace  = "default"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.47.10"
  set {
    name  = "nodeSelector.node"
    value = "app"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.max_weather.eks_cloudwatch_role_arn
  }
  set {
    name  = "config.outputs"
    value = <<-EOF
      [OUTPUT]
          Name cloudwatch_logs
          Match *
          region ${module.max_weather.region}
          log_group_name /aws/containerinsights/${module.max_weather.aws_eks_cluster_name}/host
          log_stream_prefix from-fluent-bit
          auto_create_group   true
          extra_user_agent    container-insights
    EOF
  }
  set {
    name  = "env[0].name"
    value = "AWS_REGION"
  }
  set {
    name  = "env[0].value"
    value = "us-west-2"
  }
  set {
    name  = "env[1].name"
    value = "CLUSTER_NAME"
  }
  set {
    name  = "env[1].value"
    value = "test"
  }
  set {
    name  = "env[2].name"
    value = "HTTP_SERVER"
  }
  set {
    name  = "env[2].value"
    value = "ON"
  }
  set {
    name  = "env[3].name"
    value = "HTTP_PORT"
  }
  set {
    name  = "env[3].value"
    value = "\"2020\"" # Explicitly set as string
  }
  set {
    name  = "env[4].name"
    value = "READ_FROM_HEAD"
  }
  set {
    name  = "env[4].value"
    value = "Off"
  }
  set {
    name  = "env[5].name"
    value = "READ_FROM_TAIL"
  }
  set {
    name  = "env[5].value"
    value = "On"
  }
  depends_on = [module.max_weather]
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  set {
    name  = "persistence.enabled"
    value = "false"
  }
  set {
    name  = "global.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "alertmanager.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "grafana.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "kubeStateMetrics.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "prometheusNodeExporter.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "prometheus.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "prometheusAdapter.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "prometheusOperator.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "thanos.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }
  depends_on = [module.max_weather]
}

resource "helm_release" "prometheus-adapter" {
  name       = "prometheus-adapter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  values = [file("prometheus-adapter.yaml")]
  depends_on = [module.max_weather]
}

resource "helm_release" "metric-server" {
  name       = "metric-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  set {
    name  = "nodeSelector.node"
    value = "app"
  }
  depends_on = [module.max_weather]
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.7.12"
  set {
    name  = "persistence.enabled"
    value = "false"
  }
  set {
    name  = "controller.nodeSelector.node"
    value = "app"
  }
  set {
    name  = "controller.installPlugins[0]"
    value = "kubernetes:4295.v7fa_01b_309c95"
  }
  set {
    name  = "controller.installPlugins[1]"
    value = "workflow-aggregator:600.vb_57cdd26fdd7"
  }
  set {
    name  = "controller.installPlugins[2]"
    value = "git:5.6.0"
  }
  set {
    name  = "controller.installPlugins[3]"
    value = "configuration-as-code:1887.v9e47623cb_043"
  }
  set {
    name  = "controller.installPlugins[4]"
    value = "pipeline-utility-steps:2.18.0"
  }
  set {
    name  = "controller.installPlugins[5]"
    value = "pipeline-aws:1.45"
  }
  set {
    name  = "controller.installPlugins[5]"
    value = "kubernetes-cli:1.12.1"
  }
  depends_on = [module.max_weather]
}