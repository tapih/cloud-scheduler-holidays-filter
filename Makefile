TERRAFORM_VERSION=0.12.29

all:

terraform-init:
	terraform init

terraform-apply:
	TF_VAR_PROJECT=${PROJECT} \
		TF_VAR_REGION=${REGION} \
		TF_VAR_ZONE=${ZONE} \
		terraform apply


setup: /usr/local/bin

/usr/local/bin/terraform:
	curl -sSLf https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip
	unzip /tmp/terraform.zip
	sudo mv terraform /usr/local/bin

.PHONY: setup
