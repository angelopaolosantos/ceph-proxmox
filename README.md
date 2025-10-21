<a id="readme-top"></a>

[![LinkedIn][linkedin-shield]][linkedin-url]

# Ceph Cluster on Proxmox

## 📖 About the Project
This project provides a simple way to deploy a **Ceph Cluster** on a local **Proxmox** server using virtual machines.  
It is designed for learning, experimentation, and understanding how Ceph works in a lab environment.  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ⚙️ Prerequisites

On your **local development machine**, install:

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  
- [Ansible](https://www.ansible.com/)  
- [Transcrypt](https://github.com/elasticdog/transcrypt)  
- Proxmox Server  
- PostgreSQL Server *(optional, used as Terraform backend)*  

### 🔑 Setting up Transcrypt
1. Install [Transcrypt](https://github.com/elasticdog/transcrypt).  
2. Run:
   ```bash
   transcrypt
   ```
3. Follow prompts to set a secret key.  

Transcrypt will encrypt/decrypt files listed in `.gitattributes` when pushed to Git.  

### 📦 Install Terraform Ansible Collection
After installing Ansible, install the [Terraform Collection][terraform-collection]:
```bash
ansible-galaxy collection install cloud.terraform
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Step 1 - Provision Ceph Cluster Infrastructure

1. Create a `terraform.tfvars` file with your Proxmox server credentials:
   - `proxmox_endpoint`
   - `proxmox_username`
   - `proxmox_password`

2. *(Optional)* Use PostgreSQL as a Terraform backend:  
   Create `config.pg.tfbackend` with:
   - `conn_str`
   - `schema_name`

3. Adjust IP addresses and settings in `variables.tf` if needed.  

### Default Infrastructure
- 3 Ceph nodes

### Run Terraform
```bash
terraform init --backend-config=config.pg.tfbackend
terraform plan
terraform apply
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🛠️ Step 2 - Configure the Infrastructure

### Run Ansible Playbook
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml -vvvv
```

The Terraform run in Step 1 generates a `tf_ansible_vars_file.yaml` file for Ansible.  
Use `-vvvv` for verbose output.  

---

## 🧹 Cleanup

To destroy the entire infrastructure:
```bash
terraform destroy
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📌 Useful Commands

### 🔧 Terraform & Ansible
Print Terraform inventory:
```bash
ansible-inventory -i ./ansible/inventory.yaml --graph --vars
```

Run specific Ansible tasks:
```bash
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml --tags "tag1,tag2"
```

SSH into a VM:
```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/my-private-key.pem ceph@192.168.254.109
```

Download Terraform state:
```bash
terraform state pull > terraform.tfstate
```

Show Terraform state:
```bash
terraform show -json
```

### 🐛 Terraform Troubleshooting
```bash
terraform refresh
terraform state rm <resource_name>
terraform apply -target=<resource_name>
terraform destroy -target=<resource_name>
terraform apply -replace=<resource_name>
terraform force-unlock <lock_id>
TF_LOG=DEBUG terraform apply
```

---

## 💾 Useful Ceph Commands

Run on an admin Ceph node:

Check status:
```bash
ceph -s
```

Add hosts:
```bash
ceph orch host add ceph-vm-2 192.168.254.110 --labels _admin
ceph orch host add ceph-vm-3 192.168.254.111 --labels _admin
```

List hosts:
```bash
ceph orch host ls
```

Manage OSDs:
```bash
ceph osd tree
ceph orch apply osd --all-available-devices
ceph orch device ls
```

Create CephFS:
```bash
ceph fs volume create cephfs
```

Reset dashboard admin password
Create password file
```
vi dashboard_password.yaml
# enter preferred password and save
ceph dashboard ac-user-set-password admin -i dashboard_password.yaml
```

Get service endpoints (dashboard url)
```
ceph mgr services
```

Create pools
Block Storage
In dashboard select application rds (block storage), replication 3.

CephFS Filesystem Storage
Label hosts the will be metadata servers. This is done in the dashboard. 
Metadata pools are required in cephfs type storage
```
cephadm shell
ceph fs volume create cephfs --placement="label:mds"
# check if cephfs pools are created
ceph osd pool ls
```

Object (similar to S3)
Requires a Rados Gateway, label the servers with "rgw"
```
ceph orch apply rgw radosgw '--placement=label:rgw count-per-host:1' --port:8001
# check if rgw pools are created
ceph osd pool ls
```

---

## 🔗 Resources
- [Terraform CLI Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  
- [Transcrypt Documentation](https://github.com/elasticdog/transcrypt)  

---

<!-- MARKDOWN LINKS & IMAGES -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/angelopaolosantos
[terraform-collection]: https://galaxy.ansible.com/ui/repo/published/cloud/terraform/
[Connect Multiple Kubernetes Clusters to an External Ceph Cluster]: https://www.youtube.com/watch?v=dKmpeV0sh1Q
