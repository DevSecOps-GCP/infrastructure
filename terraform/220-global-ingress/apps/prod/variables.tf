variable "hostname" {
  description = "Public hostname of the app, relative to the public zone"
  type        = string
}

variable "rate_limit_per_minute" {
  description = "Requests per minute allowed from one client IP before Cloud Armor answers 429"
  type        = number
}
