output "subscriptions" {
  description = "Subscription entries parsed from the manifest"
  value       = lookup(local.platform, "subscriptions", [])
}

output "new_subscription_ids" {
  description = "Map of newly vended subscription aliases to their subscription IDs"
  value       = { for k, v in azurerm_subscription.new : k => v.subscription_id }
}
