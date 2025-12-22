[masters]
master ansible_host=${master_public_ip} ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/k8s_key

[workers]
worker1 ansible_host=${worker_public_ip} ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/k8s_key
