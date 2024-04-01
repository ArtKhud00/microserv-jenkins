job "postgres-inventory" {
  datacenters = ["dc1"]

  group "postgres-inventory" {
    network {
      port  "db1"{
        static = 5732
        to = 5432
      }
    }

    task "postgres-inventory" {
      driver = "docker"

      config {
        image = "docker.io/postgres:15"
        ports = ["db1"]
      }
      
      env {
          POSTGRES_USER      = "user"
          POSTGRES_PASSWORD  = "password"
		  POSTGRES_DB        = "inventory-service"
      }

      service {
        name = "postgres-inventory"
        port = "db1"
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
