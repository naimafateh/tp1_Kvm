#!/bin/bash
# Partie A : vérifier la virtualisation et installer les outils
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
  virtinst virt-manager virt-viewer qemu-utils libguestfs-tools genisoimage
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt,kvm $USER
