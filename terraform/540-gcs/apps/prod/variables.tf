variable "bucket_name" {
  type = string
}

variable "app_origin" {
  description = "Origin allowed to upload to and read from the bucket in the browser"
  type        = string
}

variable "kubernetes_service_account" {
  description = "Backend Kubernetes service account, as namespace/name"
  type        = string
}
