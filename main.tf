terraform {
  required_version = "0.12.9"
}

resource "random_string" "srvpass" {
  count = length(var.devs)
  length = 12
  special = true
  lower = true
  upper = true
  number = true
  min_special = 1
  min_lower = 1
  min_upper = 1
  min_numeric = 1
  override_special = "/@£$"
}  


provider "vscale" {
  token = var.vs_token
}

resource "vscale_ssh_key" "root" {
  name = "kornyakovdy root key"
  key  = file(".ssh/id_rsa.pub")
}

resource "vscale_ssh_key" "rb" {
  name = "rebrain root key"
  key  = file(".ssh/rb.pub")
}

resource "vscale_scalet" "ansible5" {
  count     = length(var.devs)
  ssh_keys  = [vscale_ssh_key.root.id,vscale_ssh_key.rb.id]
  make_from = var.vscale_centos_7
  location  = var.vscale_msk
  rplan     = var.vscale_rplan["s"]
  name      = "${var.devs[count.index]}"

    connection {
      host     = "${self.public_address}"
      type     = "ssh"
      user     = "root"
      private_key = file("${path.module}/.ssh/id_rsa")
    }

  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname ${var.devs[count.index]}",
      "echo -e '${element(random_string.srvpass.*.result, count.index)}\n${element(random_string.srvpass.*.result, count.index)}' | passwd root"
    ]
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_acckey
  secret_key = var.aws_skey
}


data "aws_route53_zone" "rb" {
  name = "devops.rebrain.srwx.net."
}

resource "aws_route53_record" "kornyakovdy" {
  count   = length(var.devs)
  zone_id = data.aws_route53_zone.rb.zone_id
  name    = "${var.devs[count.index]}.${data.aws_route53_zone.rb.name}"
  type    = "A"
  ttl     = "300"
  records = ["${vscale_scalet.ansible5.*.public_address[count.index]}"]
}

data "template_file" "data_json" {
  template = file("${path.module}/data.tmpl")
  count    = length(var.devs)
  vars = {
    srvname = aws_route53_record.kornyakovdy.*.name[count.index]
    srvip = vscale_scalet.ansible5.*.public_address[count.index]
    srvpass = element(random_string.srvpass.*.result, count.index)
  }  
}


output "json" {
  value = data.template_file.data_json.*.rendered
}

resource "local_file" "devsjson" {
    content     = join("\n", data.template_file.data_json.*.rendered )
    filename    = "${path.module}/devs.json"
}

resource "local_file" "ans_inv_web" {
  content  = templatefile(
  "${path.module}/ans_inv_yml.tpl",
   {
     ans_inv_name = var.ansible_extra["ans_inv_name"],
     ans_inv_hosts = aws_route53_record.kornyakovdy.*.name,
     ans_extra_user = var.ansible_extra["ans_extra_user"],
     ans_extra_key = "${abspath(path.root)}/.ssh/id_rsa",
     ans_extra_wc = var.ansible_extra["ans_extra_wc"],
     ans_extra_cmbs = var.ansible_extra["ans_extra_cmbs"],
     ans_extra_vhosts = var.ansible_extra["ans_extra_vhosts"],
     ans_extra_locs = var.ansible_extra["ans_extra_locs"]
   }
  )

  filename = "${abspath(path.root)}/ansible/inventory/web.yml"
  file_permission = 0644
}

#resource "null_resource" "ansible" {
#  triggers = {
#    fileexists("${abspath(path.root)}/ansible/inventory/web.yml") = true,
#    policy_sha1 = sha1(file("${abspath(path.root)}/ansible/inventory/web.yml"))
#  }
#  provisioner "local-exec" {
#    command = "ansible-playbook -i ${abspath(path.root)}/ansible/inventory/web.yml ${abspath(path.root)}/ansible/nginx.yml"
#  }
#  depends_on = [local_file.web.yml]
#}

