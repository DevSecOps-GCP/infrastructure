# Attached to the app's backend services through a GCPBackendPolicy. Rules are evaluated
# by priority and the first match wins, so the WAF rules run before the rate limit.
resource "google_compute_security_policy" "edge" {
  project     = local.project
  name        = "learnhub-edge"
  description = "WAF and per-IP rate limiting in front of the LearnHub Gateway"
  type        = "CLOUD_ARMOR"

  advanced_options_config {
    json_parsing = "STANDARD"
    log_level    = "VERBOSE"
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }

  # OWASP ModSecurity CRS 3.3 at sensitivity 1, the level with the fewest false positives.
  # Method enforcement is left out because the API uses PUT, PATCH and DELETE.
  rule {
    action      = "deny(403)"
    priority    = 1000
    description = "OWASP CRS: SQLi, XSS, LFI, RFI, RCE"

    match {
      expr {
        expression = join(" || ", [
          "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('lfi-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('rfi-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})",
        ])
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 1100
    description = "OWASP CRS: scanner detection, protocol attacks, session fixation"

    match {
      expr {
        expression = join(" || ", [
          "evaluatePreconfiguredWaf('scannerdetection-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('protocolattack-v33-stable', {'sensitivity': 1})",
          "evaluatePreconfiguredWaf('sessionfixation-v33-stable', {'sensitivity': 1})",
        ])
      }
    }
  }

  rule {
    action      = "throttle"
    priority    = 2000
    description = "Per-client-IP rate limit"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = var.rate_limit_per_minute
        interval_sec = 60
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default rule"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
