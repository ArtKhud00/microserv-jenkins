job "zipkin" {
  datacenters = ["dc1"]
  
  group "zipkin" {
    network {
      port "http"{
        static = 9411
		    to = 9411
      }
    }

    task "zipkin" {
      driver = "docker"
            
      config {
        image = "docker.io/openzipkin/zipkin"
        ports = ["http"]
      }
      
      service {
        name = "zipkin"
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
