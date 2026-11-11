#!/bin/bash
# Partie C : clonage de la source et comparaison des identités matérielles
SRC=<vrai-nom>
IMGDIR=/var/lib/libvirt/images
sudo virsh -c qemu:///system shutdown $SRC
sudo virt-clone -c qemu:///system --original $SRC --name ${SRC}-clone \
  --file $IMGDIR/${SRC}-clone.qcow2
for v in $SRC ${SRC}-clone; do
  echo "== $v"
  sudo virsh -c qemu:///system domuuid "$v"
  sudo virsh -c qemu:///system domiflist "$v"
done
sudo qemu-img info -U $IMGDIR/${SRC}-clone.qcow2 | grep -i backing
