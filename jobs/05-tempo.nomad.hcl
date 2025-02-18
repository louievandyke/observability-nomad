job "tempo" {
  datacenters = ["dc1"]
  type        = "service"

  group "tempo" {
    count = 1

    network {
      #dns {
      #  servers = ["127.0.0.1"]
      #}
      port "tempo" {
          static = "3400"
      }
      port "tempowrite" {
        static = "6831"
      }
    }

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    task "tempo" {
      driver = "docker"

      env {
        JAEGER_AGENT_HOST    = "tempo.service.dc1.consul"
        JAEGER_TAGS          = "cluster=nomad"
        JAEGER_SAMPLER_TYPE  = "probabilistic"
        JAEGER_SAMPLER_PARAM = "1"
      }

      artifact {
        source      = "https://raw.githubusercontent.com/grafana/tempo/master/example/docker-compose/local/tempo-local.yaml"
        mode        = "file"
        destination = "/local/tempo.yml"
      }
      config {
        image = "grafana/tempo:demo"
        ports = ["tempo", "tempowrite"]
        args = [
          "-config.file=/local/tempo.yml",
          "-server.http-listen-port=${NOMAD_PORT_tempo}",
        ]
      }

      resources {
        cpu    = 200
        memory = 200
      }

      service {
        name = "tempo"
        port = "tempo"
        tags = ["monitoring","prometheus"]

        check {
          name     = "Tempo HTTP"
          type     = "http"
          path     = "/ready"
          interval = "5s"
          timeout  = "2s"

          check_restart {
            limit           = 2
            grace           = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}
