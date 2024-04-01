job "discovery-server" {
  datacenters = ["dc1"]
  
  group "discovery-server" {
    network {
      port "http"{
        static = 8761
        to = 8761
      }
    }

    task "discovery-server" {
      driver = "docker"

       template {
      data        = <<EOH
{{ range nomadService "zipkin" }}
SPRING_ZIPKIN_BASE_URL = http://{{ .Address }}:{{ .Port }}    
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
      
      config {
        image = "docker.io/artkhud20/discovery-server:2.0.0"
        ports = ["http"]
      }
      
      
      
      env {
          SPRING_PROFILES_ACTIVE = "docker"
          SPRING_ZIPKIN_BASE_URL = "$SPRING_ZIPKIN_BASE_URL"
      }

      service {
        name = "discovery-server"
        port = "http"
        provider = "nomad"

        check {
          type     = "tcp"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
