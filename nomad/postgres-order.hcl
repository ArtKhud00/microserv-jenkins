job "postgres-order" {
  datacenters = ["dc1"]

  group "postgres-order" {
    network {
      port  "db"{
        static = 5731
        to = 5432
        host_network = "private"
      }
    }

    task "postgres-order" {
      driver = "docker"

      config {
        image = "docker.io/postgres:15"
        ports = ["db"]
      }
      
      env {
          POSTGRES_USER      = "user"
          POSTGRES_PASSWORD  = "password"
		  POSTGRES_DB        = "order-service"
      }

      service {
        name = "postgres-order"
        port = "db"
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
