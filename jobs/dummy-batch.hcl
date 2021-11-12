job "dummy-batch" {
  type        = "batch"
  datacenters = ["dc1"]
  #namespace   = "test"

  parameterized {}

  group "default" {
    count = 2

    network {
      dns {
        servers = ["10.0.2.15"]
      }
      port "foo" {
        static = 8001
      }
    }
 
    task "default" {
      driver = "docker"
      config {
        image = "busybox"
        args  = ["sleep", "60"]
      }

      resources {
        cpu    = 125
        memory = 1024
      }
      service {
        name = "dummy"
        port = "foo"
        tags = ["dummy"]
      }
    }
  }
}
