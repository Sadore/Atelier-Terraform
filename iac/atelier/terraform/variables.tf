variable "pve_endpoint" {
  type        = string
  description = "URL de l'API Proxmox du binome, avec le port 8006"
}

variable "pve_api_token" {
  type        = string
  description = "Jeton au format user1@pam!terraform=secret"
  sensitive   = true
}

variable "pve_node" {
  type        = string
  description = "Nom du noeud Proxmox"
}

variable "pool" {
  type        = string
  description = "Pool sur lequel le jeton a des droits"
}

variable "passerelle" {
  type        = string
  description = "Passerelle du reseau de l'etudiant"
}

variable "pont" {
  type        = string
  description = "Pont reseau : vmbr2 pour l'etudiant 1, vmbr3 pour l'etudiant 2"
}

variable "stockage" {
  type        = string
  description = "Stockage du systeme de fichiers racine"
  default     = "local"
}

variable "template" {
  type        = string
  description = "Identifiant du template LXC"
  default     = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
}

variable "cle_publique" {
  type        = string
  description = "Chemin de la cle publique SSH a injecter"
  default     = "~/.ssh/debian_terra.pub"
}

variable "reseau" {
  type        = string
  description = "Reseau de l'etudiant, au format CIDR"
}

variable "nb_web" {
  type        = number
  description = "Nombre de serveurs web derriere le repartiteur"
  default     = 2
}

variable "ctid_proxy" { type = number } # identifiant du repartiteur
variable "hote_proxy" { type = number } # son numero d'hote dans le reseau

variable "ctid_web_base" { type = number } # identifiant du 1er serveur web
variable "hote_web_base" { type = number } # numero d'hote du 1er serveur web