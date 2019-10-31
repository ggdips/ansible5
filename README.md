# Rebrain Ansible 5

This is Ansible learning project

### Prerequisites

Download go
```
https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
cd ~ && curl -O https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.12.7.linux-amd64.tar.gz
```

Make skelet
```
mkdir -p $HOME/terraform
```

Configure env
```
echo "export GOPATH=$HOME/terraform" >> ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.bash_profile
source .bash_profile
```

Install Go
```
mkdir -p $GOPATH/src/github.com/terraform-providers; cd $GOPATH/src/github.com/terraform-providers
git clone https://github.com/burkostya/terraform-provider-vscale.git terraform-provider-vscale
```
Enter the provider directory and build the provider
```
cd terraform-provider-vscale
go get ./...
go build
```
Add plugin to terraform

```
mkdir -p ~/.terraform.d/plugins/linux_amd64/
mv terraform-provider-vscale ~/.terraform.d/plugins/linux_amd64/
```
### Running TF
Copy vars.tf.example to vars.tf
```
cp vars.tf.example vars.tf
```
Customize vars.tf
```
variable "vs_token" {
  default  = "Put your token here"
}

variable "aws_acckey" {
  default  = "Put your AWS access key here"
}

variable "aws_skey" {
  default  = "Put your AWS secret key here"
}

variable "devs" {
  type    = "list"
  default = ["PUT_NAME1_HERE", "PUT_NAME2_HERE" ...]
}

variable "ansible_extra" {
  type = "map"
  default = {
      "ans_inv_name" = "Put your inventory name here"
      "ans_extra_user" = "Put your nginx username here"
      "ans_extra_wc" = "Put your wircer connections count here"
      "ans_extra_cmbs" = "Put your client message body size here"
      "ans_extra_vhosts" = "[\"Put your vhost1_name here\", \"Put your vhost2_name here\",  \"etc..\"]"
      "ans_extra_locs" = "[\"Put your /location1 here\", \"/location2\", \"/location3\", \"/etc...\"]"
    }
}


```
```
terraform init
terraform apply
```
#Ansible Role for Nginx installation

This Ansible role installs the Nginx and configures it for running with several virtual hosts

###Requirements
Ansible, Redhat family OS
```
yum install -y ansible
```
####Role Variables
You must provide ansible:

```
                ansible_user: root
                ansible_ssh_private_key_file: /path/to/key

```
And nginx variables:
```
                nginx_worker_connections: 2048
                nginx_client_max_body_size: 64M
                nginx_locations: ["/location1", "/location2", "/location3"]
                nginx_vhosts: ["vhost1", "vhost2"]
```
### Running ansible
```
ansible-playbook -i ansible/inventory/web.yml ansible/deploy.yml
```
