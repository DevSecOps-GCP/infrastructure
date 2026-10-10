variable "hostnames" {
  description = "Hosts served by the ops gateway, as <name>.<internal domain>"
  type        = set(string)
}
