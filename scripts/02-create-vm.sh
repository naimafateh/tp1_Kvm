#!/bin/bash
# Partie B : création de la VM source depuis l'ISO Ubuntu 24.04 (BIOS, virtio, NAT default)
SRC=<vrai-nom>
TP=~/tp1_kvm
IMGDIR=/var/lib/libvirt/images
ISO=$(ls $TP/iso/ubuntu-24.04*live-server-amd64.iso | head -1)
sudo qemu-img create -f qcow2 $IMGDIR/$SRC.qcow2 15G
sudo virt-install -c qemu:///system \
  --name $SRC --memory 2048 --vcpus 2 \
  --disk path=$IMGDIR/$SRC.qcow2,format=qcow2,bus=virtio \
  --cdrom "$ISO" --os-variant ubuntu24.04 \
  --network network=default,model=virtio --graphics spice
sudo virsh -c qemu:///system dumpxml $SRC > $TP/images/source.xml
