# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = "jb-${var.env}-blue"
  region                     = var.region
  zones                      = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
  network                    = google_compute_network.main.name
  subnetwork                 = google_compute_subnetwork.private.name //"us-central1-01" 
  ip_range_pods              = "k8s-pod-range"                        //google_compute_subnetwork.private.secondary_ip_range[0].ip_cidr_range
  ip_range_services          = "k8s-service-range"                    // google_compute_subnetwork.private.secondary_ip_range[1].ip_cidr_range
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  logging_service            = "logging.googleapis.com/kubernetes"
  monitoring_service         = "monitoring.googleapis.com/kubernetes"

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "${var.region}-b,${var.region}-c"
      min_count          = 1
      max_count          = 5
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      logging_variant    = "DEFAULT"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.kubernetes.email
      preemptible        = false
      initial_node_count = 3
    },
    {
      name           = "preemptible-pool"
      machine_type   = "e2-medium"
      node_locations = "${var.region}-b,${var.region}-c"
      min_count      = 1
      max_count      = 5
      spot           = true

    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}
    default-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
    preemptible-pool = {
      node-pool-metadata-custom-value = "preemptible-node-pool"
    }
  }
  node_pools_taints = {
    all = []
    default-pool = [
      {
        key    = "default-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      }
    ]
    preemptible-pool = [
      {
        key    = "preemptible-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      }
    ]
  }

  node_pools_tags = {
    all = []
    default-pool = [
      "default-pool"
    ]
    preemptible-pool = [
      "preemptible-pool"
    ]
  }
}
