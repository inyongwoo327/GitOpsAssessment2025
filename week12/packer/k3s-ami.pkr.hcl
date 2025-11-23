# # Packer Configuration for K3s HA Node AMI
# # Uses AWS Session Manager instead of SSH (bypasses port 22 blocking)

# packer {
#   required_plugins {
#     amazon = {
#       version = ">= 1.2.8"
#       source  = "github.com/hashicorp/amazon"
#     }
#   }
# }

# # Data source to get the latest Ubuntu 22.04 AMI
# data "amazon-ami" "ubuntu" {
#   filters = {
#     name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
#     root-device-type    = "ebs"
#     virtualization-type = "hvm"
#   }
#   most_recent = true
#   owners      = [var.source_ami_owner]
#   region      = var.aws_region
# }

# source "amazon-ebs" "k3s_node" {
#   ami_name      = "${var.ami_name_prefix}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
#   instance_type = var.instance_type
#   region        = var.aws_region
#   source_ami    = data.amazon-ami.ubuntu.id
#   ssh_username  = var.ssh_username

#   communicator         = "ssh"
#   ssh_interface        = "public_ip"
#   iam_instance_profile = "PackerBuilderRole"

#   subnet_id                   = var.subnet_id != "" ? var.subnet_id : null
#   associate_public_ip_address = true

#   # Install SSM Agent at boot
#   user_data = <<EOF
# #!/bin/bash
# set -e
# mkdir -p /tmp/ssm
# cd /tmp/ssm
# curl -sSL https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb -o amazon-ssm-agent.deb
# dpkg -i amazon-ssm-agent.deb
# systemctl enable amazon-ssm-agent
# systemctl start amazon-ssm-agent
# EOF
  
#   tags = {
#     Name       = "${var.ami_name_prefix}-${formatdate("YYYY-MM-DD", timestamp())}"
#     OS         = "Ubuntu 22.04"
#     K3sVersion = var.k3s_version
#     BuildDate  = formatdate("YYYY-MM-DD", timestamp())
#     BuildTool  = "Packer"
#     Purpose    = "K3s HA Cluster Node"
#   }

#   snapshot_tags = {
#     Name       = "${var.ami_name_prefix}-snapshot-${formatdate("YYYY-MM-DD", timestamp())}"
#     K3sVersion = var.k3s_version
#   }

#   launch_block_device_mappings {
#     device_name           = "/dev/sda1"
#     volume_size           = 20
#     volume_type           = "gp3"
#     delete_on_termination = true
#   }
# }

# # Build steps (same as before)
# build {
#   name    = "k3s-ha-ami"
#   sources = ["source.amazon-ebs.k3s_node"]

#   # Step 1: Wait for cloud-init to complete
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 1: Waiting for cloud-init to complete ==='",
# #       "cloud-init status --wait || true",
# #       "echo 'Cloud-init completed successfully'"
# #     ]
# #   }

#   # Step 2: Update system packages
#   provisioner "shell" {
#     inline = [
#       "echo '=== Step 2: Updating system packages ==='",
#       "sudo apt-get update -qq",
#       "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq",
#       "sudo apt-get install -y -qq apt-transport-https ca-certificates curl git jq software-properties-common openssh-server",
#       "echo 'System packages updated successfully'"
#     ]
#   }

#   # Step 3: Install Docker
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 3: Installing Docker ==='",
# #       "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
# #       "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
# #       "sudo apt-get update -qq",
# #       "sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io",
# #       "sudo systemctl enable docker",
# #       "sudo usermod -aG docker ubuntu",
# #       "echo 'Docker installed successfully'"
# #     ]
# #   }

# #   # Step 4: Download K3s installation script
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 4: Downloading K3s installation script ==='",
# #       "curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh",
# #       "chmod +x /tmp/install-k3s.sh",
# #       "echo 'K3s installation script downloaded to /tmp/install-k3s.sh'"
# #     ]
# #   }

#   # Step 5: Install kubectl
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 5: Installing kubectl ==='",
# #       "curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'",
# #       "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
# #       "rm kubectl",
# #       "kubectl version --client --short || echo 'kubectl installed'",
# #       "echo 'kubectl installed successfully'"
# #     ]
# #   }

# #   # Step 6: Install Helm
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 6: Installing Helm ==='",
# #       "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
# #       "helm version --short || echo 'Helm installed'",
# #       "echo 'Helm installed successfully'"
# #     ]
# #   }

# #   # Step 7: Install additional tools
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 7: Installing additional tools ==='",
# #       "sudo apt-get install -y -qq htop net-tools iputils-ping dnsutils nfs-common",
# #       "echo 'Additional tools installed'"
# #     ]
# #   }

# #   # Step 8: Create K3s directories
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 8: Creating K3s directories ==='",
# #       "sudo mkdir -p /etc/rancher/k3s",
# #       "sudo mkdir -p /var/lib/rancher/k3s",
# #       "sudo chmod 755 /etc/rancher/k3s",
# #       "echo 'K3s directories ready'"
# #     ]
# #   }

# #   # Step 9: Clean up
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 9: Cleaning up ==='",
# #       "sudo apt-get autoremove -y -qq",
# #       "sudo apt-get clean",
# #       "sudo rm -rf /var/lib/apt/lists/*",
# #       "sudo rm -rf /tmp/*",
# #       "sudo rm -rf /var/tmp/*",
# #       "cat /dev/null > ~/.bash_history && history -c",
# #       "echo 'Cleanup completed'"
# #     ]
# #   }

# #   # Step 10: Create AMI info file
# #   provisioner "shell" {
# #     inline = [
# #       "echo '=== Step 10: Creating AMI info file ==='",
# #       "sudo tee /etc/ami-info.json > /dev/null <<EOF",
# #       "{",
# #       "  \"ami_name\": \"${var.ami_name_prefix}\",",
# #       "  \"k3s_version\": \"${var.k3s_version}\",",
# #       "  \"build_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",",
# #       "  \"os\": \"Ubuntu 22.04 LTS\",",
# #       "  \"tools\": [\"k3s-install-script\", \"kubectl\", \"helm\", \"docker\"]",
# #       "}",
# #       "EOF",
# #       "cat /etc/ami-info.json"
# #     ]
# #   }

# #   # Step 11: Display completion
# #   provisioner "shell" {
# #     inline = [
# #       "echo ''",
# #       "echo '=========================================='",
# #       "echo 'AMI Build Completed Successfully!'",
# #       "echo '=========================================='",
# #       "echo 'Installed: kubectl, helm, docker, K3s script'",
# #       "echo '=========================================='",
# #       "echo ''"
# #     ]
# #   }

#   post-processor "manifest" {
#     output     = "manifest.json"
#     strip_path = true
#   }
# }







# Packer Configuration for K3s HA Node AMI
# Uses AWS Session Manager (following manager's recommendation)

packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"  # Updated plugin version
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Data source to get the latest Ubuntu 22.04 AMI with SSM pre-installed
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["679593333241"]  # AWS AMI with SSM agent pre-installed (manager's recommendation)
  region      = var.aws_region
}

source "amazon-ebs" "k3s_node" {
  ami_name      = "${var.ami_name_prefix}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu.id
  
  # ⭐ CORRECTED: Use SSH communicator WITH Session Manager interface
  communicator         = "ssh"                    # Keep as "ssh" 
  ssh_interface        = "session_manager"        # This makes it use Session Manager
  ssh_username         = "ubuntu"
  iam_instance_profile = "PackerBuilderRole"
  
  # Network config - no public IP needed
  subnet_id                   = var.subnet_id != "" ? var.subnet_id : null
  associate_public_ip_address = false
  
  tags = {
    Name       = "${var.ami_name_prefix}-${formatdate("YYYY-MM-DD", timestamp())}"
    OS         = "Ubuntu 22.04"
    K3sVersion = var.k3s_version
    BuildDate  = formatdate("YYYY-MM-DD", timestamp())
    BuildTool  = "Packer"
    Purpose    = "K3s HA Cluster Node"
  }

  snapshot_tags = {
    Name       = "${var.ami_name_prefix}-snapshot-${formatdate("YYYY-MM-DD", timestamp())}"
    K3sVersion = var.k3s_version
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

# Build steps
build {
  name    = "k3s-ha-ami"
  sources = ["source.amazon-ebs.k3s_node"]

  # Step 1: Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo '=== Step 1: Waiting for cloud-init to complete ==='",
      "cloud-init status --wait || true",
      "echo 'Cloud-init completed successfully'"
    ]
  }

  # Step 2: Update system packages
  provisioner "shell" {
    inline = [
      "echo '=== Step 2: Updating system packages ==='",
      "sudo apt-get update -qq",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq",
      "sudo apt-get install -y -qq apt-transport-https ca-certificates curl git jq software-properties-common",
      "echo 'System packages updated successfully'"
    ]
  }

  # Step 3: Install Docker
  provisioner "shell" {
    inline = [
      "echo '=== Step 3: Installing Docker ==='",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -qq",
      "sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "echo 'Docker installed successfully'"
    ]
  }

  # Step 4: Download K3s installation script
  provisioner "shell" {
    inline = [
      "echo '=== Step 4: Downloading K3s installation script ==='",
      "curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh",
      "chmod +x /tmp/install-k3s.sh",
      "echo 'K3s installation script downloaded to /tmp/install-k3s.sh'"
    ]
  }

  # Step 5: Install kubectl
  provisioner "shell" {
    inline = [
      "echo '=== Step 5: Installing kubectl ==='",
      "curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'",
      "sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
      "rm kubectl",
      "kubectl version --client || echo 'kubectl installed'",
      "echo 'kubectl installed successfully'"
    ]
  }

  # Step 6: Install Helm
  provisioner "shell" {
    inline = [
      "echo '=== Step 6: Installing Helm ==='",
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "helm version || echo 'Helm installed'",
      "echo 'Helm installed successfully'"
    ]
  }

  # Step 7: Install additional tools
  provisioner "shell" {
    inline = [
      "echo '=== Step 7: Installing additional tools ==='",
      "sudo apt-get install -y -qq htop net-tools iputils-ping dnsutils nfs-common",
      "echo 'Additional tools installed'"
    ]
  }

  # Step 8: Create K3s directories
  provisioner "shell" {
    inline = [
      "echo '=== Step 8: Creating K3s directories ==='",
      "sudo mkdir -p /etc/rancher/k3s",
      "sudo mkdir -p /var/lib/rancher/k3s",
      "sudo chmod 755 /etc/rancher/k3s",
      "echo 'K3s directories ready'"
    ]
  }

  # Step 9: Clean up
  provisioner "shell" {
    inline = [
      "echo '=== Step 9: Cleaning up ==='",
      "sudo apt-get autoremove -y -qq",
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "cat /dev/null > ~/.bash_history && history -c",
      "echo 'Cleanup completed'"
    ]
  }

  # Step 10: Create AMI info file
  provisioner "shell" {
    inline = [
      "echo '=== Step 10: Creating AMI info file ==='",
      "sudo tee /etc/ami-info.json > /dev/null <<EOF",
      "{",
      "  \"ami_name\": \"${var.ami_name_prefix}\",",
      "  \"k3s_version\": \"${var.k3s_version}\",",
      "  \"build_date\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",",
      "  \"os\": \"Ubuntu 22.04 LTS\",",
      "  \"tools\": [\"k3s-install-script\", \"kubectl\", \"helm\", \"docker\"]",
      "}",
      "EOF",
      "cat /etc/ami-info.json"
    ]
  }

  # Step 11: Display completion
  provisioner "shell" {
    inline = [
      "echo ''",
      "echo '=========================================='",
      "echo 'AMI Build Completed Successfully!'",
      "echo '=========================================='",
      "echo 'Installed: kubectl, helm, docker, K3s script'",
      "echo '=========================================='",
      "echo ''"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}