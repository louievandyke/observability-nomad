job "tns" {
  datacenters = ["dc1"]
  type        = "service"

  group "tns" {
    count = 1

    network {
      port "db" {
        static = 8000
      }

      port "app" {
        static = 8001
      }

      port "loadgen" {
        static = 8002
      }
    }

    restart {
      attempts = 5
      interval = "10s"
      delay    = "2s"
      mode     = "delay"
    }

    task "db" {
      driver = "docker"

      config {
        image = "grafana/tns-db"
        ports = ["db"]

        args = [
          "-log.level=debug",
          "-server.http-listen-port=${NOMAD_PORT_db}",
        ]
      }

      service {
        name = "db"
        port = "db"
        tags = ["app"]
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "grafana/tns-app"
        ports = ["app"]

        args = [
          "-log.level=debug",
          "-server.http-listen-port=${NOMAD_PORT_app}",
          "http://db.service.dc1.consul:${NOMAD_PORT_db}",
        ]
      }

      service {
        name = "app"
        port = "app"
        tags = ["app"]
      }
    }

    task "loadgen" {
      driver = "docker"

      config {
        image = "grafana/tns-loadgen"
        ports = ["loadgen"]

        args = [
          "-log.level=debug",
          "-server.http-listen-port=${NOMAD_PORT_loadgen}",
          "http://app.service.dc1.consul:${NOMAD_PORT_app}",
        ]
      }

      service {
        name = "loadgen"
        port = "loadgen"
        tags = ["app"]
      }
    }
  }
}
