#!/bin/bash
set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Main build process
main() {
    print_header "Building K3s HA Node AMI"
    echo ""
    
    # Check if AWS credentials are configured
    print_info "Checking AWS credentials..."
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured!"
        echo "Please run: aws configure"
        echo "Or set environment variables:"
        echo "  export AWS_ACCESS_KEY_ID=your-key"
        echo "  export AWS_SECRET_ACCESS_KEY=your-secret"
        exit 1
    fi
    print_success "AWS credentials found"
    
    # Display AWS account info
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region || echo "eu-west-1")
    print_info "AWS Account: $ACCOUNT_ID"
    print_info "AWS Region: $AWS_REGION"
    echo ""
    
    # Check if Packer is installed
    print_info "Checking Packer installation..."
    if ! command -v packer &> /dev/null; then
        print_error "Packer is not installed!"
        echo ""
        echo "Install Packer:"
        echo "  macOS:  brew install packer"
        echo "  Linux:  wget https://releases.hashicorp.com/packer/1.10.0/packer_1.10.0_linux_amd64.zip"
        echo "          unzip packer_*.zip && sudo mv packer /usr/local/bin/"
        exit 1
    fi
    PACKER_VERSION=$(packer version | head -n1)
    print_success "Packer found: $PACKER_VERSION"
    echo ""
    
    # Initialize Packer (download required plugins)
    print_header "Step 1: Initializing Packer"
    if packer init .; then
        print_success "Packer initialized successfully"
    else
        print_error "Packer initialization failed"
        exit 1
    fi
    echo ""
    
    # Validate Packer configuration
    print_header "Step 2: Validating Packer Configuration"
    if packer validate .; then
        print_success "Packer configuration is valid"
    else
        print_error "Packer validation failed"
        echo "Please check your .pkr.hcl files for syntax errors"
        exit 1
    fi
    echo ""
    
    # Display build information
    print_header "Step 3: Build Information"
    echo "The following AMI will be created:"
    echo "  • Base OS: Ubuntu 22.04 LTS"
    echo "  • K3s installation script: Pre-downloaded"
    echo "  • Tools: kubectl, Helm, Docker"
    echo "  • Region: $AWS_REGION"
    echo "  • Instance Type: t3.small (for building)"
    echo ""
    print_info "Build will take approximately 5-10 minutes"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed with the build? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Build cancelled by user"
        exit 0
    fi
    echo ""
    
    # Build the AMI
    print_header "Step 4: Building AMI"
    print_info "This will take 5-10 minutes. Please wait..."
    echo ""
    
    # Run Packer build with timestamp
    BUILD_START=$(date +%s)
    
    if packer build -color=true .; then
        BUILD_END=$(date +%s)
        BUILD_DURATION=$((BUILD_END - BUILD_START))
        BUILD_MINUTES=$((BUILD_DURATION / 60))
        BUILD_SECONDS=$((BUILD_DURATION % 60))
        
        echo ""
        print_header "Build Completed Successfully!"
        print_success "Build took ${BUILD_MINUTES}m ${BUILD_SECONDS}s"
    else
        print_error "Packer build failed"
        echo ""
        echo "Troubleshooting tips:"
        echo "  1. Check AWS permissions (EC2, AMI creation)"
        echo "  2. Verify network connectivity"
        echo "  3. Check available disk space"
        echo "  4. Review error messages above"
        exit 1
    fi
    echo ""
    
    # Extract AMI ID from manifest
    print_header "Step 5: Extracting AMI Information"
    
    if [ ! -f "manifest.json" ]; then
        print_error "manifest.json not found"
        exit 1
    fi
    
    AMI_ID=$(cat manifest.json | jq -r '.builds[0].artifact_id' | cut -d':' -f2)
    AMI_NAME=$(cat manifest.json | jq -r '.builds[0].custom_data.ami_name' || echo "k3s-ha-node")
    
    if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "null" ]; then
        print_error "Failed to extract AMI ID from manifest"
        exit 1
    fi
    
    print_success "AMI created successfully!"
    echo ""
    echo "AMI Details:"
    echo "  • AMI ID: $AMI_ID"
    echo "  • Region: $AWS_REGION"
    echo ""
    
    # Save AMI ID to file
    echo "$AMI_ID" > ami-id.txt
    print_success "AMI ID saved to: ami-id.txt"
    echo ""
    
    # Display next steps
    print_header "Next Steps"
    echo ""
    echo "1. Update your Terraform configuration:"
    echo "   ${YELLOW}vim ../terraform/terraform.tfvars${NC}"
    echo ""
    echo "   Add this line:"
    echo "   ${GREEN}custom_ami_id = \"$AMI_ID\"${NC}"
    echo ""
    echo "2. Verify the AMI in AWS Console:"
    echo "   https://console.aws.amazon.com/ec2/home?region=$AWS_REGION#Images:"
    echo ""
    echo "3. Test the AMI (optional):"
    echo "   ${YELLOW}aws ec2 run-instances \\${NC}"
    echo "   ${YELLOW}     --image-id $AMI_ID \\${NC}"
    echo "   ${YELLOW}     --instance-type t3.small \\${NC}"
    echo "   ${YELLOW}     --key-name your-key-name${NC}"
    echo ""
    echo "4. Deploy your infrastructure:"
    echo "   ${YELLOW}cd ../terraform${NC}"
    echo "   ${YELLOW}terraform init -upgrade${NC}"
    echo "   ${YELLOW}terraform plan${NC}"
    echo "   ${YELLOW}terraform apply${NC}"
    echo ""
    
    print_header "Build Summary"
    echo "AMI ID: ${GREEN}$AMI_ID${NC}"
    echo "Location: ami-id.txt"
    echo "Manifest: manifest.json"
    echo ""
    print_success "AMI build complete! 🎉"
    echo ""
}

# Run main function
main