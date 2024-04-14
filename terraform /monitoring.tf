terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "localprom" {
  name = "localprom"
}

resource "docker_container" "prometheus" {
  image        = "prom/prometheus"
  name         = "prometheus"
  ports {
    internal = 9090
    external = 9090
  }
  network_mode = "localprom"
}

resource "docker_container" "grafana" {
  image        = "grafana/grafana:latest"
  name         = "grafana"
  ports {
    internal = 3000
    external = 3000
  }
  network_mode = "localprom"
}

resource "docker_container" "ruby_app_latest" {
  image        = "oluwasanmivic123/docker_web:latest"
  name         = "ruby-app-latest"
  ports {
    internal = 3000
    external = 4000
  }
  network_mode = "localprom"
  depends_on   = [docker_container.prometheus, docker_container.grafana]
}

resource "docker_container" "ruby_app_v1" {
  image        = "oluwasanmivic123/docker_web:v1"
  name         = "ruby-app-v1"
  ports {
    internal = 3000
    external = 4001
  }
  network_mode = "localprom"
  depends_on   = [docker_container.prometheus, docker_container.grafana]
}

resource "docker_container" "cadvisor" {
  image        = "gcr.io/cadvisor/cadvisor:v0.47.2"
  name         = "cadvisor"
  ports {
    internal = 8080
    external = 8080
  }
  network_mode = "localprom"
  depends_on   = [docker_container.prometheus, docker_container.grafana]
  privileged   = true
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = false
  }
  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only      = true
  }
}

resource "docker_container" "node_exporter" {
  image        = "quay.io/prometheus/node-exporter:v1.5.0"
  name         = "node_exporter"
  ports {
    internal = 9100
    external = 9100
  }
  command      = ["--path.rootfs=/"]
  network_mode = "localprom"
  restart      = "unless-stopped"
}

resource "docker_container" "loki" {
  image        = "grafana/loki:latest"
  name         = "loki"
  ports {
    internal = 3100
    external = 3100
  }
  command      = ["-config.file=/etc/loki/local-config.yaml"]
  volumes {
    host_path      = "/tmp/loki"
    container_path = "/tmp/loki"
  }
  volumes {
    host_path      = "/absolute/path/to/local-config.yaml"
    container_path = "/etc/loki/local-config.yaml"
  }
  restart      = "unless-stopped"
  user         = "root"
  network_mode = "localprom"
}
