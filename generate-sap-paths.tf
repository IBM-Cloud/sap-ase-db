# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.KIT_ASE_FILE}
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.DB_HOSTNAME}"
}