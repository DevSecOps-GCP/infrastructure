resource "google_billing_budget" "trial" {
  billing_account = var.billing_account
  display_name    = "${var.folder_name}-trial-credit"

  amount {
    specified_amount {
      units = "300"
    }
  }

  budget_filter {
    # Credits make trial usage net to ~0; track gross cost so the alerts actually fire.
    credit_types_treatment = "EXCLUDE_ALL_CREDITS"
  }

  dynamic "threshold_rules" {
    for_each = [0.25, 0.5, 0.75, 0.9, 1.0]
    content {
      threshold_percent = threshold_rules.value
    }
  }

  depends_on = [google_project_service.this]
}
