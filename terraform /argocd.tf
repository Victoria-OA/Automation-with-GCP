provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [
    <<-EOT
{
  "global": {
    "image": {
      "tag": "v2.6.6"
    }
  },
  "dex": {
    "enabled": false
  },
  "server": {
    "extraArgs": [
      "--insecure"
    ]
  }
}
    EOT
  ]
}
