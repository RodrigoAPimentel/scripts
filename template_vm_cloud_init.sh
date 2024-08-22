IMAGE=/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img
IMAGE_DEST=externalbay
VM_ID=101
VM_NAME=ubuntu-server-2204-noble-cloud-init
VM_SOCKETS=1
VM_CORES=2
VM_MEMORY=2048
VM_HD=20g
SSH_PUB_KEY=

echo "##### Install libguestfs-tools"
apt install libguestfs-tools -y

echo "##### Customize Base Image >> Install: qemu-guest-agent,nano,wget"
virt-customize --add $IMAGE --install qemu-guest-agent,nano,wget --run-command 'systemctl enable qemu-guest-agent.service'
echo "##### Customize Base Image >> Run Command: apt-get update -y && apt-get upgrade -y"
virt-customize --add $IMAGE --run-command 'apt-get update -y && apt-get upgrade -y'
echo "##### Customize Base Image >> Run Command: sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
virt-customize --add $IMAGE --run-command 'sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf'

echo "##### Create VM: qm create $VM_ID --name $VM_NAME --numa 0 --ostype l26 --cpu cputype=host --cores $VM_CORES --sockets $VM_SOCKETS --memory $VM_SOCKETS --net0 virtio,bridge=vmbr0"
qm create $VM_ID \
 --name $VM_NAME \
 --numa 0 \
 --ostype l26 \
  --cpu cputype=host \
  --cores $VM_CORES \
  --sockets $VM_SOCKETS \
  --memory $VM_SOCKETS \
  --net0 virtio,bridge=vmbr0

echo "##### Importdisk: $VM_ID $IMAGE $IMAGE_DEST"
qm importdisk $VM_ID $IMAGE $IMAGE_DEST

echo "##### QM set disk"
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $IMAGE_DEST:vm-$VM_ID-disk-0

echo "##### QM set cloudinit"
qm set $VM_ID --ide2 $IMAGE_DEST:cloudinit

echo "##### QM set boot disk"
qm set $VM_ID --boot c --bootdisk scsi0

echo "##### QM set vga"
qm set $VM_ID --serial0 socket --vga serial0

echo "##### QM agent enable"
qm set $VM_ID --agent enabled=1

echo "##### QM disk resize"
qm disk resize $VM_ID scsi0 +$VM_HD

# echo "##### Create Template"
# qm template $VM_ID