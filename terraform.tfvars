# -----------------------------------------------------------------------------
# terraform.tfvars
# Values for the variables declared in variables.tf.
# Terraform loads this file automatically. Other .tfvars files can be passed
# explicitly, e.g. `terraform plan -var-file="prod.tfvars"`.
# -----------------------------------------------------------------------------

# Your Azure subscription ID (find it with: az account show --query id -o tsv)
# Leave empty to use the ARM_SUBSCRIPTION_ID environment variable instead.
subscription_id = ""

prefix   = "tfdemo"
location = "ukwest"
vm_size  = "Standard_B2s"

# allowed_rdp_cidr is deliberately not set here. Terraform will prompt for it,
# or pass it in explicitly, e.g.:
#   terraform apply -var="allowed_rdp_cidr=<your-public-ip>/32"
#   $env:TF_VAR_allowed_rdp_cidr = "<your-public-ip>/32"   (PowerShell)
# Find your public IP with: curl ifconfig.me

tags = {
  environment = "demo"
  owner       = "terraform-intro"
}
