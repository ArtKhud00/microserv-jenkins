job "inventory-service" {
  datacenters = ["dc1"]
  
  group "inventory-service" {
    network {
      mode = "host"
      port "http3"{
        static = 9193
        to = 8080
      }
    }

    task "inventory-service" {
      driver = "docker"

      template {
      data        = <<EOH
{{ range nomadService "postgres-inventory" }}
SPRING_DATASOURCE_URL=jdbc:postgresql://{{ .Address }}:{{ .Port }}/inventory-service
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
        image = "docker.io/artkhud20/inventory-service:2.0.1"
        ports = ["http3"]
      }
      
      
      
      env {
          #SPRING_DATASOURCE_URL = "$SPRING_DATASOURCE_URL"
          SPRING_DATASOURCE_URL = "jdbc:postgresql://postgres-inventory:5732/inventory-service"
          SPRING_PROFILES_ACTIVE = "docker"
       	  EUREKA_CLIENT_SERVICEURL_DEFAULTZONE= "$EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
          EUREKA_INSTANCE_PREFERIPADDRESS = "true"
          SPRING_ZIPKIN_BASE_URL = "$SPRING_ZIPKIN_BASE_URL"
      }

      service {
        name = "inventory-service"
        port = "http3"
        provider = "nomad"
        address_mode = "driver"

        check {
          type     = "tcp"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
