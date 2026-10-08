terraform {
  backend "gcs" {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "161-artifact-registry"
  }
}
