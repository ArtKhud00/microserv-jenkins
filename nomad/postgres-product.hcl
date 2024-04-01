job "postgres-product" {
  datacenters = ["dc1"]

  group "postgres-product" {
    network {
      port  "db"{
        static = 5734
        to = 5432
      }
    }

    task "postgres-product" {
      driver = "docker"

      config {
        image = "docker.io/postgres:15"
        ports = ["db"]
      }
      
      env {
          POSTGRES_USER      = "user"
          POSTGRES_PASSWORD  = "password"
		      POSTGRES_DB        = "storehousedb"
      }

      service {
        name = "postgres-product"
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
