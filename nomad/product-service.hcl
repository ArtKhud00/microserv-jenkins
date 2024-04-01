job "product-service" {
  datacenters = ["dc1"]

  group "product-service" {
    network {
      port "http"{
        static = 9191
        to = 8080
      }
      mode = "host"
    }

    task "product-service" {
      driver = "docker"

      template {
      data        = <<EOH
{{ range nomadService "postgres-product" }}
SPRING_DATASOURCE_URL=jdbc:postgresql://{{ .Address }}:{{ .Port }}/storehousedb
{{ end }}
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
        image = "docker.io/artkhud20/product-service:2.0.1"
        ports = ["http"]
      }
      
      env {
          SPRING_DATASOURCE_URL = "$SPRING_DATASOURCE_URL"
          SPRING_PROFILES_ACTIVE = "docker"
          EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = "$EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
          EUREKA_INSTANCE_PREFERIPADDRESS = "true"
          SPRING_ZIPKIN_BASE_URL = "$SPRING_ZIPKIN_BASE_URL"
      }

      service {
        name = "product-service"
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
