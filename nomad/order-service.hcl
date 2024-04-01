job "order-service" {
  datacenters = ["dc1"]
  
  group "order-service" {
    network {
      port "http"{
        static = 9192
        to = 8080
      }
    }

    task "order-service" {
      driver = "docker"

      template {
      data        = <<EOH
{{ range nomadService "postgres-order" }}
SPRING_DATASOURCE_URL=jdbc:postgresql://{{ .Address }}:{{ .Port }}/order-service
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
        image = "docker.io/artkhud20/order-service:2.0.1"
        ports = ["http"]
      }
      
      
      
      env {
          #SPRING_DATASOURCE_URL = "$SPRING_DATASOURCE_URL"
          SPRING_DATASOURCE_URL = "$jdbc:postgresql://postgres-order:5731/order-service"
          SPRING_PROFILES_ACTIVE = "docker"
       		EUREKA_CLIENT_SERVICEURL_DEFAULTZONE= "$EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
          EUREKA_INSTANCE_PREFERIPADDRESS = "true"
          SPRING_ZIPKIN_BASE_URL = "$SPRING_ZIPKIN_BASE_URL"
      }

      service {
        name = "order-service"
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
