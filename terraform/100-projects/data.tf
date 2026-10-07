data "terraform_remote_state" "organization" {
  backend = "gcs"

  config = {
    bucket = "project-bb8996af-ebec-47fd-869-tfstate"
    prefix = "000-organization"
  }
}
