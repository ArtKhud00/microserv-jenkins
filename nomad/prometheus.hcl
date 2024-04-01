job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "monitoring" {
    count = 1

    network {
      mode = "host"
      port "prometheus_ui" {
        static = 9090
        to = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     10s
  evaluation_interval: 10s

scrape_configs:
  - job_name: 'product_service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['192.168.253.129:9191']
        labels:
          application: 'Product Service Application'
  - job_name: 'order_service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['192.168.253.129:9192']
        labels:
          application: 'Order Service Application'
  - job_name: 'inventory_service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['172.17.0.8:8080']
        labels:
          application: 'Inventory Service Application'
EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:v2.37.1"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]

        ports = ["prometheus_ui"]
      }

      service {
        name = "prometheus"
        port = "prometheus_ui"
        provider = "nomad"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

