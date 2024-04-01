job "api-gateway" {
  datacenters = ["dc1"]
  
  group "api-gateway" {
    network {
      port "http"{
        static = 8181
        to = 8080
      }
    }

    task "api-gateway" {
      driver = "docker"
  
      template {
      data        = <<EOH
{{ range nomadService "discovery-server" }}
EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = http://eureka:password@{{ .Address }}:{{ .Port }}/eureka      
{{ end }}
{{ range nomadService "zipkin" }}
SPRING_ZIPKIN_BASE_URL = http://{{ .Address }}:{{ .Port }}    
{{ end }}
EOH      
        destination = "local/env.txt"
        env         = true
      }
      
      
      config {
        image = "docker.io/artkhud20/api-gateway:2.0.0"
        ports = ["http"]
      }
      
      
      
      env {
          SPRING_PROFILES_ACTIVE = "docker"
          LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY = "'TRACE'"
          EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = "$EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
          SPRING_ZIPKIN_BASE_URL = "$SPRING_ZIPKIN_BASE_URL"
      }

      service {
        name = "api-gateway"
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
