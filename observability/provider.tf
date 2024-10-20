terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.10.0"  
    }
    http = {
      source = "hashicorp/http"
      version = "~>3.0"
    }
  }
}

provider "grafana" {
  url  = "" 
  auth = "AUTH TOKEN"
}

provider "http" {}

