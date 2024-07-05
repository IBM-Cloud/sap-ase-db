variable "KIT_ASE_FILE" {
	type		= string
	description = "KIT_ASE_FILE"
    validation {
    condition = fileexists("${trimspace(var.KIT_ASE_FILE)}") == true
    error_message = "The PATH  does not exist."
    }
}
