# Google Cloud VPC and GKE Cluster

This Terraform configuration sets up a Google Cloud VPC network and a Google Kubernetes Engine (GKE) cluster.

## Overview

The Terraform configuration includes the following components:

1. **provider.tf**: Defines the Google Cloud provider and configures the Terraform backend to use a Google Cloud Storage (GCS) bucket for storing the state file.
2. **vpc.tf**: Sets up the Google Cloud VPC network with a single regional network and related resources.
3. **subnets.tf**: Creates a private subnet within the VPC network, enabling private Google Access and defining secondary IP ranges for Kubernetes pods and services.
4. **router.tf** and **nat.tf**: Configures a Google Cloud Router and a NAT Gateway to allow private instances to access the internet.
5. **firewall.tf**: Creates a firewall rule to allow SSH traffic from a specific IP range.
6. **kubernetes.tf**: Sets up the GKE cluster, including the creation of a service account for the Kubernetes nodes.
7. **variables.tf**: Defines the input variables for the Terraform configuration.
8. **outputs.tf**: Defines the output values that will be available after the Terraform deployment.

## Prerequisites

- Terraform version 1.1.0 or newer
- Google Cloud SDK
- Google Cloud account with the necessary permissions to create resources

## Usage

1. Clone the repository or copy the Terraform configuration files to your local machine.
2. Initialize the Terraform working directory:
```
terraform init
```
3. Review and modify the input variables in the `variables.tf` file as needed.
4. plan with variables by updating <ENV>.tfvars replace env based on your environment
   
```
terraform plan --var-file=<ENV>.tfvars 
```

5. Once, plan is verified and haoppy with changes, Apply the Terraform configuration:
```
terraform appply --var-file=<ENV>.tfvars 
```
5. Review the output values after the deployment is complete.

## Outputs

The Terraform configuration provides the following output values:

- `region`: The region of the GKE cluster.
- `project_id`: The Google Cloud project ID.
- `kubernetes_endpoint`: The endpoint URL for the Kubernetes API server.
- `client_token`: The base64-encoded access token for the Kubernetes client.
- `service_account`: The default service account used for running Kubernetes nodes.
