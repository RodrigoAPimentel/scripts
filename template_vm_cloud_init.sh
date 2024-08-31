IMAGE=/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img
IMAGE_DEST=externalbay
VM_ID=100
VM_NAME=ubuntu-server-2204-noble-cloud-init
VM_SOCKETS=1
VM_CORES=2
VM_MEMORY=2048
VM_HD=20G
CREATE_TEMPLATE=false

echo ">>>>>>>>>>>>> 1/14 >>> Install [apt install libguestfs-tools -y]"
apt install libguestfs-tools -y

echo ">>>>>>>>>>>>> 2/14 >>> Customize Base Image [virt-customize --add $IMAGE --install qemu-guest-agent,nano,wget,ncat,net-tools,bash-completion --run-command 'systemctl enable qemu-guest-agent.service']"
virt-customize --add $IMAGE --install qemu-guest-agent,nano,wget,ncat,net-tools,bash-completion --run-command 'systemctl enable qemu-guest-agent.service'

echo ">>>>>>>>>>>>> 3/14 >>> Customize Base Image [virt-customize --add $IMAGE --run-command 'apt-get update -y && apt-get upgrade -y']"
virt-customize --add $IMAGE --run-command 'apt-get update -y && apt-get upgrade -y'

echo ">>>>>>>>>>>>> 4/14 >>> Customize Base Image [virt-customize --add $IMAGE --run-command "sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"]"
virt-customize --add $IMAGE --run-command "sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"

echo ">>>>>>>>>>>>> 5/14 >>> Create VM [qm create $VM_ID --name $VM_NAME --numa 0 --ostype l26 --cpu cputype=host --cores $VM_CORES --sockets $VM_SOCKETS --memory $VM_MEMORY --net0 virtio,bridge=vmbr0]"
qm create $VM_ID --name $VM_NAME --numa 0 --ostype l26 --cpu cputype=host --cores $VM_CORES --sockets $VM_SOCKETS --memory $VM_MEMORY --net0 virtio,bridge=vmbr0

echo ">>>>>>>>>>>>> 6/14 >>> Import Disk [qm importdisk $VM_ID $IMAGE $IMAGE_DEST]"
qm importdisk $VM_ID $IMAGE $IMAGE_DEST

echo ">>>>>>>>>>>>> 7/14 >>> Set Disk [qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 externalbay:$VM_ID/vm-$VM_ID-disk-0.raw]"
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 externalbay:$VM_ID/vm-$VM_ID-disk-0.raw

echo ">>>>>>>>>>>>> 8/14 >>> Set Cloudinit [qm set $VM_ID --ide2 $IMAGE_DEST:cloudinit]"
qm set $VM_ID --ide2 $IMAGE_DEST:cloudinit

echo ">>>>>>>>>>>>> 9/14 >>> Set Boot Disk [qm set $VM_ID --boot c --bootdisk scsi0]"
qm set $VM_ID --boot c --bootdisk scsi0

echo ">>>>>>>>>>>>> 10/14 >>> Set VGA [qm set $VM_ID --serial0 socket --vga serial0]"
qm set $VM_ID --serial0 socket --vga serial0

echo ">>>>>>>>>>>>> 11/14 >>> Agent Enable [qm set $VM_ID --agent enabled=1]"
qm set $VM_ID --agent enabled=1

echo ">>>>>>>>>>>>> 12/14 >>> Disk Resize [qm disk resize $VM_ID scsi0 +$VM_HD]"
sleep 5
qm disk resize $VM_ID scsi0 +$VM_HD

echo ">>>>>>>>>>>>> 13/14 >>> Install Docker [qm set $VM_ID --cicustom "user=local:snippets/cloud-config_install-docker.yml"]"
qm set $VM_ID --cicustom "user=local:snippets/cloud-config_install-docker.yml"

echo ">>>>>>>>>>>>> 14/14 >>> Transform in Template [qm template $VM_ID]"
if [ "$CREATE_TEMPLATE" == "true" ]; then
  qm template $VM_ID
elif [ "$CREATE_TEMPLATE" == "false" ]; then
  echo "!!!!! CREATE TEMPLATE DISABLE !!!!!"
fi