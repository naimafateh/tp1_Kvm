#!/bin/bash
# Parties D et E : capture de l'image, généralisation, création du template
SRC=ubuntu-vm01
IMGDIR=/var/lib/libvirt/images
sudo virsh -c qemu:///system shutdown $SRC
sudo qemu-img convert -O qcow2 $IMGDIR/$SRC.qcow2 $IMGDIR/ubuntu-os-capture-v1.qcow2
sha256sum $IMGDIR/ubuntu-os-capture-v1.qcow2
# Dans la VM, avant l'arrêt : sudo cloud-init clean --logs --seed
sudo cp $IMGDIR/ubuntu-os-capture-v1.qcow2 $IMGDIR/ubuntu-template-v1.qcow2
sudo virt-sysprep -a $IMGDIR/ubuntu-template-v1.qcow2 \
  --operations machine-id,ssh-hostkeys,udev-persistent-net,logfiles,tmp-files,bash-history
sudo qemu-img info -U $IMGDIR/ubuntu-template-v1.qcow2
sha256sum $IMGDIR/ubuntu-template-v1.qcow2
