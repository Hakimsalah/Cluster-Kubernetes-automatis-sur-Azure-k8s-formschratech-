# =====================
# VARIABLES GLOBALES
# =====================

variable "resource_group_name" {
  description = "Nom du resource group"
}

variable "location" {
  description = "Région Azure (ex: FranceCentral)"
}

variable "vnet_name" {
  description = "Nom du réseau virtuel"
}

variable "subnet_name" {
  description = "Nom du subnet"
}

variable "admin_username" {
  description = "Nom d'utilisateur admin pour les VMs"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
}

# =====================
# TAILLE DES VMS
# =====================
variable "vm_sizem" {
  description = "Taille de la VM master"
  default     = "Standard_B2s"  # Master 2 vCPU
}

variable "vm_sizew" {
  description = "Taille des VM workers"
  default     = "Standard_B2s"  # Worker 2 vCPU
}
