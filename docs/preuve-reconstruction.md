# Preuve de reconstruction de l'infrastructure

Cette preuve montre la destruction complète de l'infrastructure, sa reconstruction avec Terraform, sa configuration avec Ansible et le test du répartiteur de charge Nginx.

## 1. Destruction de l'infrastructure

Commande exécutée :

```bash
cd ~/scripts-infra/iac/atelier/terraform
terraform destroy
```

Résultat :

```text
Plan: 0 to add, 0 to change, 3 to destroy.

proxmox_virtual_environment_container.proxy: Destroying... [id=225]
proxmox_virtual_environment_container.web[1]: Destroying... [id=227]
proxmox_virtual_environment_container.web[0]: Destroying... [id=226]

proxmox_virtual_environment_container.proxy: Destruction complete after 4s
proxmox_virtual_environment_container.web[0]: Destruction complete after 4s
proxmox_virtual_environment_container.web[1]: Destruction complete after 5s

Destroy complete! Resources: 3 destroyed.
```

## 2. Reconstruction avec Terraform

Commande exécutée :

```bash
terraform apply
```

Terraform prévoit la création des trois conteneurs :

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

Création :

```text
proxmox_virtual_environment_container.web[0]: Creating...
proxmox_virtual_environment_container.web[1]: Creating...
proxmox_virtual_environment_container.proxy: Creating...

proxmox_virtual_environment_container.web[1]: Creation complete after 7s [id=227]
proxmox_virtual_environment_container.web[0]: Creation complete after 7s [id=226]
proxmox_virtual_environment_container.proxy: Creation complete after 8s [id=225]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

Sorties Terraform :

```text
adresse_proxy = "192.168.200.20"

adresses_web = [
  "192.168.200.21",
  "192.168.200.22",
]
```

L'infrastructure reconstruite est donc composée de :

- `srv-proxy` : `192.168.200.20`
- `srv-web-01` : `192.168.200.21`
- `srv-web-02` : `192.168.200.22`

## 3. Configuration avec Ansible

Après le démarrage complet des conteneurs :

```bash
cd ../ansible
ansible-playbook site.yml
```

Résultat :

```text
PLAY [Socle commun sur toutes les machines]

TASK [Gathering Facts]
ok: [srv-proxy]
ok: [srv-web-01]
ok: [srv-web-02]

TASK [Les paquets de base sont installes]
changed: [srv-proxy]
changed: [srv-web-01]
changed: [srv-web-02]

TASK [Le message d'accueil identifie la machine]
changed: [srv-proxy]
changed: [srv-web-01]
changed: [srv-web-02]

PLAY [Serveurs web]

TASK [nginx est installe]
changed: [srv-web-01]
changed: [srv-web-02]

TASK [La page d'accueil identifie la machine]
changed: [srv-web-01]
changed: [srv-web-02]

TASK [nginx est demarre et actif au boot]
ok: [srv-web-01]
ok: [srv-web-02]

PLAY [Repartiteur de charge]

TASK [nginx est installe]
changed: [srv-proxy]

TASK [Le site par defaut est desactive]
changed: [srv-proxy]

TASK [La configuration du repartiteur est generee]
changed: [srv-proxy]

TASK [nginx est demarre et actif au boot]
ok: [srv-proxy]

RUNNING HANDLER [Redemarrer nginx]
changed: [srv-proxy]

PLAY RECAP
srv-proxy  : ok=9 changed=6 unreachable=0 failed=0
srv-web-01 : ok=7 changed=4 unreachable=0 failed=0
srv-web-02 : ok=7 changed=4 unreachable=0 failed=0
```

## 4. Test du répartiteur de charge

Commande exécutée :

```bash
for i in $(seq 1 6); do
  curl -s http://192.168.200.20 | grep -o 'srv-web-[0-9][0-9]'
done
```

Résultat :

```text
srv-web-01
srv-web-01
srv-web-02
srv-web-01
srv-web-02
srv-web-01
```

Les réponses proviennent bien des deux serveurs web. Le répartiteur Nginx transmet donc les requêtes aux différents backends.

## Conclusion

L'infrastructure peut être entièrement détruite puis reconstruite avec Terraform.

Ansible configure ensuite automatiquement les trois conteneurs et génère la configuration du répartiteur Nginx.

Le test HTTP final confirme que les deux serveurs web sont accessibles via le répartiteur de charge.
