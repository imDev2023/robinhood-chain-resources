> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Login with AWS CLI for Blockscout Terraform Deploy

> Authenticate the AWS CLI with aws configure for Blockscout Terraform deployment: enter access key, secret, region us-east-1, and JSON output.

use `aws configure` in the cli to connect your account for Terraform deployment. You will be prompted to enter the following. See [Creating a Secret Key Pair](/setup/deployment/ansible-deployment/aws-permissions/creating-a-secret-key-pair) for more information.

* AWS Access Key ID: \<*your\_access\_key\_id*>
* AWS Secret Access Key: \<*your\_secret\_access\_key*>
* Default region name: **us-east-1** Use this, as Terraform has known issues with other regions
* Default output format: json
