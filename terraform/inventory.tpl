[masters]
master ansible_host=${master_public_ip} ansible_user=azureuser

[workers]
worker1 ansible_host=${worker_public_ip} ansible_user=azureuser
