############################################################
# General & Default VPC variables for CLI deployment
############################################################

variable "PRIVATE_SSH_KEY" {
        type            = string
        description = "The id_rsa private key content in OpenSSH format. This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
        nullable = false
        validation {
        condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
        error_message = "The content for PRIVATE_SSH_KEY variable must be completed in OpenSSH format."
     }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_abap_ase-syb_dst"
}

variable "SSH_KEYS" {
        type            = list(string)
        description = "List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
        validation {
                condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
                error_message = "At least one SSH KEY is needed to be able to access the VSI."
        }
}

variable "BASTION_FLOATING_IP" {
        type            = string
        description = "The BASTION FLOATING IP. It can be copied from the Bastion Server Deployment \"OUTPUTS\" at the end of \"Apply plan successful\" message."
        nullable = false
        validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for VSIs and Volumes resources. Default value: \"Default\". The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups."
  default     = "Default"
}

variable "REGION" {
        type            = string
        description     = "The cloud region where to deploy the solution. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
        validation {
                condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
                error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
        }
}

variable "ZONE" {
        type            = string
        description     = "The cloud zone where to deploy the solution."
        validation {
                condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
                error_message = "The ZONE is not valid."
        }
}

variable "VPC" {
        type            = string
        description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
        validation {
                condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
                error_message = "The VPC name is not valid."
        }
}

variable "SUBNET" {
        type            = string
        description = "The name of an EXISTING Subnet. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
        validation {
                condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
                error_message = "The SUBNET name is not valid."
        }
}

variable "SECURITY_GROUP" {
        type            = string
        description = "The name of an EXISTING Security group. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
        validation {
                condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
                error_message = "The SECURITY_GROUP name is not valid."
        }
}

##############################################################
# The variables used in Activity Tracker service.
##############################################################

variable "ATR_NAME" {
  type        = string
  description = "The name of the EXISTING Activity Tracker instance, in the same region as HANA VSI. The list of available Activity Tracker is available here: https://cloud.ibm.com/observe/activitytracker"
  default = ""
}

variable "DB_HOSTNAME" {
	type		= string
        description = "The Hostname for the DB VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
        description = "The instance profile used for the VSI. A list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	default		= "bx2-4x16"
}

variable "DB_IMAGE" {
	type		= string
        description = "The OS image used for SYBASE VSI. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-applications-6"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-6-amd64-sap-applications|ibm-redhat-8-4-amd64-sap-applications|ibm-sles-15-3-amd64-sap-applications|ibm-sles-15-4-amd64-sap-applications)-[0-9][0-9]*", var.DB_IMAGE)) > 0
		error_message = "The OS SAP IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-applications-x\", \"ibm-sles-15-4-amd64-sap-applications-x\", \"ibm-redhat-8-4-amd64-sap-applications-x\" or \"ibm-redhat-8-6-amd64-sap-applications-x\"."
	}
}

data "ibm_is_instance" "db-vsi" {
  depends_on = [module.db-vsi]
  name    =  var.DB_HOSTNAME
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "ASE_SID" {
        type            = string
        description = "The SAP ASE system ID. Identifies the entire SAP system. Consists of exactly three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280"
        default         = "NWD"
        validation {
                condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.ASE_SID)) > 0 && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.ASE_SID)
                error_message = "The ASE_SID is not valid."
        }
}

variable "ASE_MASTER_PASSWORD" {
        type            = string
        sensitive = true
        description = "Common password for all users that are created during the installation. It must be 8 to 14 characters long, it must contain at least one digit (0-9) and one uppercase letter, it must not contain backslash and double quote."
        validation {
        condition = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.ASE_MASTER_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.ASE_MASTER_PASSWORD)) > 0 && length(regexall("[A-Z]", var.ASE_MASTER_PASSWORD)) > 0
        error_message = "The ASE_MASTER_PASSWORD is not valid."
        }
}

variable "DATA_DISK_SIZE" {
        type            = string
        default         = "30"
        description = "The size of data disk, in GB."
        validation {
                condition     = var.DATA_DISK_SIZE != "" && var.DATA_DISK_SIZE != null
                error_message = "At least one data disk size should be provided."
        }
}

variable "KIT_ASE_FILE" {
	type		= string
	description = "KIT_ASE_FILE"
	default		= "/storage/ASEDB/SP04/PL06/ASESERV160004P_6-80008862.TGZ"
        validation {
                condition     = length(regexall("ASESERV\\d+P.*_\\d+-\\d+\\.TGZ$", trimspace(var.KIT_ASE_FILE))) > 0 
                error_message = "The name of the ASE Kit file must be the one downloaded from SAP Software Center and must follow the pattern \"ASESERV<version_and_SP>_<patch_level>-<number>.TGZ\"."
        }
}

# ATR variables and conditions
locals {
	ATR_ENABLE = true
}

resource "null_resource" "check_atr_name" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  lifecycle {
    precondition {
      condition     = var.ATR_NAME != "" && var.ATR_NAME != null
      error_message = "The name of an EXISTENT Activity Tracker in the same region must be specified."
    }
  }
}

data "ibm_resource_instance" "activity_tracker" {
  count             = local.ATR_ENABLE == true ? 1 : 0
  name              = var.ATR_NAME
  location          = var.REGION
  service           = "logdnaat"
}

