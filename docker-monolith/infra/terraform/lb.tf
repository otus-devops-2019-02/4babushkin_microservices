resource "google_compute_target_pool" "terraform_lb" {
  name = "terraform-lb"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.puma_port.name}",
  ]
}

resource "google_compute_forwarding_rule" "default" {
  name = "default-rule"

  target = "${google_compute_target_pool.terraform_lb.self_link}"

  port_range = "9292"
}

resource "google_compute_http_health_check" "puma_port" {
  name               = "puma-port"
  port               = "9292"
  timeout_sec        = 5
  check_interval_sec = 5
}
