job "grafana" {
  datacenters = ["dc1"]
  
  group "grafana" {
    network {
      port "http"{
        static = 3000
	to = 3000
      }
    }
	
	task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana-oss:8.5.2"
        ports = ["http"]
      }

      env {
          GF_SECURITY_ADMIN_USER="admin"
          GF_SECURITY_ADMIN_PASSWORD="password"
      }
	  
      service {
        name = "grafana"
        port = "http"
		provider = "nomad"
				
        check {
          type = "tcp"
          interval = "10s"
          timeout = "4s"
        }
      }
    }
  }
}



