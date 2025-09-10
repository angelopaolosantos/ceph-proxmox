<a id="readme-top"></a>

[![LinkedIn][linkedin-shield]][linkedin-url]

# Ceph Cluster in Proxmox

## About the Project

This project lets you run a Ceph Cluster on a local Proxmox Server using virtual machines. This is useful for tinkering with ceph and understanding how it works. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Prerequisites

* On your local dev machine install:
  * Terraform
  * Ansible
  * Transcrypt
* Proxmox Server
* Postgresql Server (optional, used as Terraform backend)

Install [Transcrypt](https://github.com/elasticdog/transcrypt) then run command `transcrypt` on the terminal. 
Follow prompts to set secret key. 
Transcrypt will encrypt and decrypt files listed in .gitattributes to git.  

After installing ansible, install the [Terraform Collection][terraform-collection] using ansible galaxy.
```
ansible-galaxy collection install cloud.terraform
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Step 1 - Provisioning the ceph cluster infrastructure

Create a terraform.tfvars file with the access credentials of your proxmox server. Enter values for 
* proxmox_endpoint
* proxmox_username
* proxmox_password

I'm using postgres as a terraform backend. This is optional. You may use your preferred backend. 
Create a config.pg.tfbackend file with access credentials to a postresql server. Enter values for
* conn_str
* schema_name

You can make changes to the variable.tf file to adjust ip addresses to the proxmox's network and infastructure. 

Default infastructure consists of:
* 3 ceph nodes

#### Run Terraform
```
terraform init --backend-config=config.pg.tfbackend 
terraform plan
terraform apply
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Step 2 - Configuring the infastructure

#### Run Ansible Playbook
```
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml -vvvv
```
Terraform command ran in step 1 generates a tf_ansible_vars_file.yaml that ansible can use in running tasks. -vvvv added for verbose output.

### Cleanup
Delete all created infastructure.
`terraform destroy`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

##### Useful commands to know:
Print Terraform Inventory
```
ansible-inventory -i ./ansible/inventory.yaml --graph --vars
```

Run specific tasks of ansible playbook
```
ansible-playbook -i ./ansible/inventory.yaml ./ansible/playbook.yaml --tags "tag1,tag2"
```

SSH into container
```
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i .ssh/my-private-key.pem ubuntu@192.168.254.101
```

Download terraform state from backend
```
terraform state pull > terraform.tfstate
```

View terraform state
```
terraform show -json
```


Troubleshooting Terraform
```
terraform refresh
terraform state rm <resource_name>
terraform apply -target=<resource_name>
terraform destroy -target=<resource_name>
terraform apply -replace=<resource_name>
terraform force-unlock <lock_id>
TF_LOG=DEBUG terraform apply
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Useful Ceph commands:
ssh into an admin ceph node and run the commands

Ceph status
```
ceph -s
```

Adding Hosts
```
ceph orch host add ceph-vm-2 192.168.254.110 --labels _admin
ceph orch host add ceph-vm-3 192.168.254.111 --labels _admin
```

List Hosts
```
ceph orch host ls
```

Adding OSDs
```
ceph osd tree
ceph orch apply osd --all-available-devices
ceph orch device ls
```

Creating cephfs
```
ceph fs volume create cephfs
```

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/angelopaolosantos
[product-screenshot]: images.png
[terraform-collection]: https://galaxy.ansible.com/ui/repo/published/cloud/terraform/


https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
https://github.com/elasticdog/transcrypt