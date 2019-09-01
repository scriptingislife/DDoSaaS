provider "aws" {
    region = "us-east-2"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "Allow SSH on port 22"
    vpc_id = "vpc-c16ea8a8"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "allow_egress_all" {
    name = "allow_egress_all"
    description = "Allow all outbound traffic"
    vpc_id = "vpc-c16ea8a8" # Hard-coded VPC

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_spot_instance_request" "spot_instance" {
    count = 25
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t3a.nano"
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_egress_all.id}"]
    key_name = "AWSDefault"
    tags = {
        Name = "ddosaas${count.index}"
    }
}

#resource "aws_instance" "ddosaas" {
#    count = 20
#    ami = "${data.aws_ami.ubuntu.id}"
#    instance_type = "t2.nano"
#    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_egress_all.id}"]
#    key_name = "AWSDefault"
#    subnet_id = "subnet-c905e6b2" # Hard-coded subnet
#
#    tags = {
#        Name = "ddosaas${count.index}"
#    }
#}

#resource "null_resource" "provision_vms" {
#    provisioner "local-exec" {
#        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ~/.ssh/AWSDefault -i '${join(",", aws_instance.ddosaas.*.public_ip)},' -e 'ansible_python_interpreter=/usr/bin/python3' provision.yml"
#    }
#}