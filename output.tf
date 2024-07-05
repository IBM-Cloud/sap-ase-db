output "DB_HOSTNAME" {
  value		= module.db-vsi.HOSTNAME
}

output "DB_PRIVATE_IP" {
  value		= module.db-vsi.PRIVATE-IP
}

output "STORAGE_LAYOUT" {
  value = module.db-vsi.STORAGE-LAYOUT
}

output "ATR_INSTANCE_NAME" {
  description = "Activity Tracker instance name."
  value       = var.ATR_NAME
}
