variable "hostname" {
  description = "Public hostname of the app, relative to the public zone"
  type        = string
}

variable "rate_limit_per_minute" {
  description = "Requests per minute allowed from one client IP before Cloud Armor answers 429"
  type        = number
}

variable "cloud_armor_enabled" {
  description = "Cloud Armor policy for the app; needs a non-zero security policies quota in the prod project"
  type        = bool
}

variable "waf_enabled" {
  description = "Preconfigured OWASP WAF rules; they need the advanced-rules quota, which is 0 on free-trial billing accounts"
  type        = bool
}
