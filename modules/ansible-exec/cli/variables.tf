variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format."
}

variable "ASE_MASTER_PASSWORD" {
    type = string
    description = "ASE_MASTER_PASSWORD"
}

variable "PLAYBOOK" {
    type = string
    description = "SAP Ansible Playbook"
}

