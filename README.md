# TP1 : Virtualisation avec KVM/QEMU/libvirt

Master BD2C (Big Data et Cloud Computing), FSAC, module Virtualisation et Cloud Computing.

Ce TP crée et administre des machines virtuelles Ubuntu Server 24.04 avec KVM/QEMU/libvirt : installation depuis une ISO, clonage, capture d'image, template, déploiement avec cloud-init et comparaison des formats de disque.

## Arborescence

```
tp1_kvm/
├── README.md
├── iso/            ISO Ubuntu Server 24.04 (non versionnée) et SHA256SUMS
├── images/         XML des VM, fiche d'image, somme de contrôle, formats/
├── templates/      fiche du template et somme de contrôle
└── scripts/
    ├── 01-install-kvm.sh
    ├── 02-create-vm.sh
    ├── 03-clone-vm.sh
    ├── 04-create-template.sh
    ├── 05-manage-vms.sh
    └── cloud-init/ seed-app01/ et seed-app02/ (user-data, meta-data)
```

## Environnement

- Hôte : Ubuntu (VM VMware) avec virtualisation imbriquée
- Hyperviseur : KVM/QEMU, gestion par libvirt (`qemu:///system`)
- Réseau : NAT `default` (DHCP)
- Invité : Ubuntu Server 24.04.5 LTS, x86_64, BIOS, disque virtio

## Partie A : préparer l'environnement

Vérification de la virtualisation, installation des outils (qemu-kvm, libvirt, virtinst, libguestfs-tools, genisoimage) et activation de `libvirtd`.
Script : `scripts/01-install-kvm.sh`

## Partie B : créer et administrer une VM

- Téléchargement de l'ISO Ubuntu 24.04 Server et vérification de la somme de contrôle (`iso/SHA256SUMS`)
- Vérification du réseau NAT `default`
- Création de la VM source `ubuntu-vm01` (2 vCPU, 2048 Mio, disque qcow2 de 15 Go) avec `virt-install`
- Installation d'Ubuntu Server, connexion, sauvegarde du XML (`images/source.xml`)
- Installation des paquets (cloud-init, qemu-guest-agent, openssh-server), fichier témoin, relevé de l'IP, arrêt propre et redémarrage

Script : `scripts/02-create-vm.sh`

## Partie C : cloner une VM

- Arrêt de la source puis clonage avec `virt-clone`
- Comparaison des identités matérielles : UUID et adresse MAC différents, machine-id et hostname identiques au départ
- Preuve de l'indépendance des disques : aucun `backing file` (`qemu-img info`)

Script : `scripts/03-clone-vm.sh`

## Partie D : capturer l'image d'OS

- Vérification du firmware (BIOS, pas de loader ni de nvram) et rédaction de la fiche d'image
- Conversion en `ubuntu-os-capture-v1.qcow2` avec `qemu-img convert`
- Réimportation dans un disque de travail avec `virt-install --import`, puis test du système réimporté

| Champ | Valeur |
|---|---|
| Identifiant | ubuntu-os-capture-v1 |
| Distribution | Ubuntu Server 24.04.5 LTS, x86_64 |
| Format | qcow2, capacité virtuelle 15 GiB, taille réelle 3,25 GiB |
| Logiciels | cloud-init, qemu-guest-agent, openssh-server |
| Matériel | BIOS, disque virtio, réseau NAT default en DHCP (enp1s0) |
| Comptes/données | compte tp1, /opt/tp1/version.txt |
| Statut | capture non généralisée |
| SHA256 | d7bfe33d2431f6d2e8f9cd01d92ef33be9123f8a8b5d018bcf28ef5d44119f08 |

Fichiers : `images/fiche-image-v1.txt`, `images/capture.sha256`, `images/capture-config.xml`

## Partie E : construire le template

- Démarrage de la source seule, vérification des paquets
- Configuration de cloud-init (datasource NoCloud) et contrôle du réseau
- Nettoyage : `cloud-init clean --logs --seed`, puis arrêt
- Généralisation d'une copie avec `virt-sysprep` (machine-id, ssh-hostkeys, udev-persistent-net, logfiles, tmp-files, bash-history)

| Champ | Valeur |
|---|---|
| Template | ubuntu-template-v1 |
| Matériel attendu | BIOS, disque virtio, réseau NAT virtio, 2 vCPU, 2048 Mio |
| Compte conservé | tp1 (compte pédagogique, usage console) |
| Personnalisation | cloud-init NoCloud (user-data / meta-data, volume cidata) |
| Restrictions | artefact de laboratoire, non audité, ne pas diffuser |
| SHA256 | b04b86ca2973fb95a1cc373626bc910885b1e24763a897728daed48e57e9b7a9 |

Script : `scripts/04-create-template.sh`
Fichiers : `templates/fiche-template-v1.txt`, `templates/template.sha256`

## Partie F : déployer app01 et app02 depuis le template

- Création de la clé SSH
- Fichiers cloud-init de chaque VM (`user-data`, `meta-data`) : hostname, utilisateur avec sudo sans mot de passe, connexion uniquement par clé SSH (mot de passe verrouillé)
- Génération de l'ISO `cidata` avec `genisoimage`
- Création de `ubuntu-app01` et `ubuntu-app02` avec `virt-install --import`
- Validation : UUID, MAC, hostname et machine-id propres à chaque VM, disques indépendants

Script : `scripts/05-manage-vms.sh`
Fichiers : `scripts/cloud-init/seed-app01/` et `scripts/cloud-init/seed-app02/`

## Partie G : formats d'images

```bash
qemu-img create -f raw disque-raw.img 5G
qemu-img create -f qcow2 disque-qcow2.qcow2 5G
qemu-img info disque-raw.img
qemu-img info disque-qcow2.qcow2
qemu-img convert -p -f raw -O qcow2 disque-raw.img disque-converti.qcow2
qemu-img info disque-converti.qcow2
qemu-img compare -f raw -F qcow2 disque-raw.img disque-converti.qcow2
```

Les deux disques ont une capacité virtuelle de 5 GiB. Le fichier RAW est un fichier creux (disk size : 4 KiB) : l'espace n'est alloué qu'à l'écriture, mais un RAW rempli occuperait 5 Go. Le QCOW2 occupe 196 KiB à vide (métadonnées) et ne grossit qu'avec les données écrites. La conversion RAW vers QCOW2 conserve le contenu : `qemu-img compare` confirme l'identité.
Fichiers : `images/formats/`

## Fichiers non versionnés

Ces fichiers sont trop volumineux pour GitHub (limite de 100 Mo par fichier) et restent en local :

- `iso/` : ISO Ubuntu Server 24.04 (somme de contrôle dans `iso/SHA256SUMS`)
- `images/` : `ubuntu-app01.qcow2`, `ubuntu-app02.qcow2`, `ubuntu-os-capture-v1.qcow2`, `disque-raw.img`
- `templates/` : `ubuntu-template-v1.qcow2` (somme de contrôle dans `templates/template.sha256`)

## Remarques

Les scripts documentent les commandes du TP. Ne pas les relancer sur la même machine : ils recréeraient des VM et écraseraient des disques existants.
