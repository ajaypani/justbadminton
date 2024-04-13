# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
#Cloud Router to advertise routes
resource "google_compute_router" "router" {
  name = "router"
  region = "europe-west2"
  network = google_compute_network.main.id
  project = "test-sp01"
}