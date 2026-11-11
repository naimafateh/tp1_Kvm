#!/bin/bash
# Partie F : déploiement de app01 et app02 depuis le template (cloud-init NoCloud)
IMGDIR=/var/lib/libvirt/images
CI=~/tp1_kvm/scripts/cloud-init
for N in app01 app02; do
  (cd $CI/seed-$N && genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data)
  sudo qemu-img convert -O qcow2 $IMGDIR/ubuntu-template-v1.qcow2 $IMGDIR/ubuntu-$N.qcow2
  sudo virt-install -c qemu:///system --name ubuntu-$N --import \
    --memory 2048 --vcpus 2 --os-variant ubuntu24.04 \
    --disk path=$IMGDIR/ubuntu-$N.qcow2,bus=virtio \
    --disk path=/var/lib/libvirt/boot/ubuntu-$N-seed.iso,device=cdrom \
    --network network=default,model=virtio --noautoconsole
done
for v in ubuntu-app01 ubuntu-app02; do
  echo "== $v"
  sudo virsh -c qemu:///system domuuid "$v"
  sudo virsh -c qemu:///system domiflist "$v"
  sudo qemu-img info -U $IMGDIR/$v.qcow2 | grep -i backing
done
