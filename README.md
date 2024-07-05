# SAP ASE installation using Terraform and Ansible Automation

## Description
This solution will perform automated deployment of **SAP ASE DB** on top of one of the following Operating Systems: **Red Hat Enterprise Linux 8.6 for SAP, Red Hat Enterprise Linux 8.4 for SAP**, **SUSE Linux Enterprise Server 15 SP 4 for SAP, SUSE Linux Enterprise Server 15 SP 3 for SAP**. The SAP ASE will be deployed  in an existing IBM Cloud Gen2 VPC, using a deployed [bastion host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).
The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment the VSI, in an EXISTING VPC, with Subnet and Security Group. The VSI is intended to be used for the data base instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP VSI deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the **SAP Adaptive Server Enterprise (ASE)** installation.
- Ansible scripts for LVM setup, specific OS settings and ASE SYB installation.
Please note that Ansible is started by Terraform and must be available on the same host.

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified.  
IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen. 

## Contents

- [1.1 Installation media](#11-installation-media)
- [1.2 VSI Configuration](#12-vsi-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General input variabiles](#15-general-input-variables)
- [2.1 Executing the deployment of **Standard SAP Netweaver and ASE installation** in GUI (Schematics)](#21-executing-the-deployment-of-standard-sap-netweaver-and-ase-installation-in-gui-schematics)
- [2.2 Executing the deployment of **Standard SAP Netweaver and ASE installation** in CLI](#22-executing-the-deployment-of-standard-sap-netweaver-and-ase-installation-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Adaptive Server Enterprise 16.0.4** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 VSI Configuration
The VSI is deployed with one of the following Operating Systems: **Red Hat Enterprise Linux 8.6 for SAP Applications (amd64), Red Hat Enterprise Linux 8.4 for SAP Applications (amd64), Suse Enterprise Linux 15 SP4 for SAP Applications (amd64), Suse Enterprise Linux 15 SP3 for SAP Applications (amd64)**. The SSH keys are configured to allow root user access.

The following storage volumes are created:

SAP ASE VSI Disks:
- 1 x 30 GB disk with 10 IOPS / GB - DATA (by default, but the size will be the one chosen for DATA_DISK_SIZE) 
- 1 x 32 GB disk with 10 IOPS / GB - DATA
- 1 x 48 GB disk with 10 IOPS / GB - SWAP (by default, but the size depends on the OS profile used)
- 1 x 64 GB disk with 3 IOPS / GB (general-purpose) - DATA

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.3 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.4 Files description and structure

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

 - `modules` - directory containing the terraform modules.
 - `ansible`  - directory containing the SAP ansible playbooks.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (VPC, Hostname, Private IP).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI.
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

## 1.5 General Input variables

**General input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys) 
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | BASTION FLOATING IP. It can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 

**Activity Tracker input parameters**

Parameter | Description
----------|------------
ATR_NAME | ATR_NAME The name of an existent Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available here Example: ATR_NAME="Activity-Tracker-SAP-eu-de".

**VSI input parameters**

Parameter | Description
----------|------------
DB_HOSTNAME | The Hostname for the DB VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE |  The profile used for the DB VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
DB_IMAGE | The OS image used for the DB VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).

**SAP input parameters**

Parameter | Description | Requirements
----------|-------------|-------------
ASE_SID | The SAP ASE system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
DATA_DISK_SIZE | The size of data disk, in GB. Default value 30 GB.
KIT_ASE_FILE | Path to SAP ASE DB archive (TGZ) | As downloaded from SAP Support Portal
 
**SAP ASE Password** <br />

The passwords for the SAP ASE system will be hidden during the schematics apply step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
ASE_MASTER_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

**Obs**: <br />
- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field, also is not displayed in your tf files details after terrafrorm plan&apply commands for CLI Deployments<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

**Installation media validated for this solution:**

---
SAP ASE
---

Component | Version | Filename
----------|-------------|-------------
SAP ASESERV | 16 SP04 PL 06 | ASESERV160004P_6-80008862.TGZ

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP Applications (amd64) | ibm-redhat-8-6-amd64-sap-applications-6 | DB
SUSE Linux Enterprise Server 15 SP4 for SAP Applications | ibm-sles-15-4-amd64-sap-applications-8 | DB
Red Hat Enterprise Linux 8.4 for SAP Applications (amd64) | ibm-redhat-8-4-amd64-sap-applications-10 | DB
SUSE Linux Enterprise Server 15 SP3 for SAP Applications | ibm-sles-15-3-amd64-sap-applications-11 | DB

## 2.1 Executing the deployment of **Standard SAP Netweaver and ASE installation** in GUI (Schematics)

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY"" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables. These are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:
**VSI input parameters:**

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | The id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_abap_ase-syb_dst

### Steps to follow

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics `Apply Plan` the private IP address of the VSI host, the hostname of the VSI, the storage layout and the Activity Tracker instance name will be displayed.


## 2.2 Executing the deployment of **Standard SAP Netweaver and ASE installation** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostnames, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

```shell
##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = "eu-de"  
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-1"    
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

VPC = "ic4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_abap_syb_dst" , "~/.ssh/id_rsa_abap_syb_dst" , "/root/.ssh/id_rsa".

##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME="Activity-Tracker-SAP-eu-de"
# The name of the Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

##########################################################
# DB VSI variables:
##########################################################

DB_HOSTNAME = "ic4sapdb"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: DB-HOSTNAME = "ic4sapdb"

DB_PROFILE = "bx2-4x16"
# The DB VSI profile. Supported profiles for DB VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-6"
# OS image for DB VSI. Supported OS images for DB VSIs: ibm-redhat-8-6-amd64-sap-applications-6, ibm-redhat-8-4-amd64-sap-applications-10, ibm-sles-15-4-amd64-sap-applications-8, ibm-sles-15-3-amd64-sap-applications-11. 
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB-IMAGE = "ibm-sles-15-4-amd64-sap-applications-8"
```

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
##########################################################
# SAP system configuration
##########################################################

ASE_SID = "NWD"
# The SAP ASE system ID. Identifies the entire ASE system.
# Consists of exactly three alphanumeric characters and the first character must be a letter.
# Does not include any of the reserved IDs listed in SAP Note 1979280

DATA_DISK_SIZE = "30"
# The size of data disk, in GB.

##########################################################
# Kit Paths
##########################################################

KIT_ASE_FILE = "/storage/ASEDB/SP04/PL06/ASESERV160004P_6-80008862.TGZ"
```

## Steps to reproduce

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY'  and  'ASE_MASTER_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY'  and  'ASE_MASTER_PASSWORD'.
```

### 3.1 Related links

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
