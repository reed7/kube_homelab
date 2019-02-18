## CentOS7 setup
* Setup static IP
* Turn off swap (swapoff -a and remove the entry on /etc/fstab, then reboot)
* kube_install_centos.sh
* Master only: kube_master_files/kube_master_init.sh

## RPI setup
* A Linux server is required for writing files to ext4 file system
* Burn Respbian to SD card: RPI/setup_os/make-rpi.sh (make-rpi.sh <node_name> <ip_suffix>)
* Run ansible from macbook: ansible-playbook RPI/ansible/setup_kube_rpi_nodes.yml 
