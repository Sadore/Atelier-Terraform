output "adresse_proxy" {
  value = cidrhost(var.reseau, var.hote_proxy)
}

output "adresses_web" {
  value = [for i in range(var.nb_web) : cidrhost(var.reseau, var.hote_web_base + i)]
}