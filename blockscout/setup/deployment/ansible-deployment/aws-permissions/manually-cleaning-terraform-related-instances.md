> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Manually Clean Terraform Instances on AWS

> Manually remove leftover AWS resources when Terraform destroy fails during Blockscout Ansible deployment, including S3, DynamoDB, and EC2 cleanup.

<Warning>
  If the deployment process was previously successful, you can run `bin/infra destroy`. Additionally, `bin/infra destroy_setup` will delete the DynamoDB table. [More information on destroying infrastructure is available here](/setup/deployment/ansible-deployment/destroying-provisioned-infrastructure).

  However, in circumstances that rely on insufficient AWS account rights, the deployment process may fail. In this case, `bin/infra destroy_setup` will not work.

  **Additionally, forgetting to clean resources can result in high AWS costs in a short period of time, so it's best to check that all resources have been removed.**
</Warning>

In order to completely manually remove Terraform deployment from AWS you need to clear all related instances of the following services:

* S3
* CodeDeploy
* DynamoDB
* Route 53
* VPC
* RDS

### Removing S3 Buckets

1\) In the Find Services box, type in S3 and select **S3, Scalable Storage in the Cloud**.

<Frame caption="Enter S3 in the Find Services Search Box">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/6474f14b-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=18b5b52bda8701bacf44b95575021096" width="2304" height="1378" data-path="images/6474f14b-image.jpeg" />
</Frame>

2\) Find related buckets created by Terraform one by one. You can only delete one at a time. They all will be prefixed with `${prefix}` from the Terraform config file. Select a bucket and click **Delete** button. Confirm the deletion. Continue for all related buckets.

<Frame caption="Select each instance and click Delete. Confirm and repeat for all instances.">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/93cf44b9-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=d7f013b813caae98d5cbc3e1677dfa77" width="2304" height="1034" data-path="images/93cf44b9-image.jpeg" />
</Frame>

### Removing CodeDeploy Application

1\) In the Find Services box, type in **CodeDeploy** and select.

<Frame caption="Enter in CodeDeploy">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/1ac9b1c3-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=6c7f3e5e722e39917d1fc2ea1684de7d" width="2304" height="1238" data-path="images/1ac9b1c3-image.jpeg" />
</Frame>

2\) Select the **Applications** section in the left menu. Click an application in the list (related to Terraform deployment) to select.

<Frame caption="Go to Applications and click on the instance name">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/05a54d86-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=77576b28a3d23a322aadf858bde437da" width="2304" height="1070" data-path="images/05a54d86-image.jpeg" />
</Frame>

Click the **Delete Application** button and confirm the deletion.

<Frame caption="Delete Application">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/9f6daecf-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=9d5c4cd2089650105d6c6b44bc655884" width="2304" height="1051" data-path="images/9f6daecf-image.jpeg" />
</Frame>

### Remove DynamoDB instance

1\) In the Find Services box, type in **DynamoDB** and select.

<Frame caption="Enter DynamoDB">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/c3f2e079-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=a083d64c285e0ee53e039488e382bc03" width="2304" height="1197" data-path="images/c3f2e079-image.jpeg" />
</Frame>

2\) Remove all related DynamoDBs.

1. Select **Tables** section in the left menu
2. Select related database (typically 1 database per deployment). Select database
3. Click **Delete Table** button.
4. Confirm the deletion.

<Frame caption="Delete the selected table. Repeat if necessary.">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/dc94d155-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=f92bf8a7a57bd30b2b2efb81532c810c" width="2304" height="1197" data-path="images/dc94d155-image.jpeg" />
</Frame>

###

1\) In the Find Services box, type in **Route 53** and select.

<Frame caption="Enter Route 53">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/7734be70-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=3ac3d5518b364b5159ae3ab035c09ac5" width="2304" height="1197" data-path="images/7734be70-image.jpeg" />
</Frame>

2\) Remove all related Hosted zones.

1. Select hosted zones in left menu.
2. Select related hosted zone.
3. Click **Delete Hosted Zone** button.
4. Confirm the deletion.

<Frame caption="Delete related hosted zones">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/bcf5cb99-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=1b39e82217056651201ab2fde9651e17" width="2304" height="1197" data-path="images/bcf5cb99-image.jpeg" />
</Frame>

###

1\) In the Find Services box, type in **VPC** and select.

<Frame caption="Enter and select VPC">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/94517f44-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=ddc45aaf8dbfecfc0d3f888af9429fcb" width="2304" height="1197" data-path="images/94517f44-image.jpeg" />
</Frame>

2\) Remove all related subnets. Select **Subnets** section in the left menu, select all related subnets (usually 1 subnet per deployment). Right mouse click or click **Delete subnet** item in **Actions** menu. Confirm the deletion.

<Frame caption="Select subnet to delete, right click, select Delete subnet and confirm deletion.">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/df6bbb24-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=d557993f97afe9dad8158263fb18bd25" width="2304" height="1828" data-path="images/df6bbb24-image.jpeg" />
</Frame>

3\) Remove all related route tables. Select **Route tables** section in the left menu, select all related route tables (usually it should be 1 route table for deployment). Right mouse click or click **Delete Route table** item in **Actions** menu. Confirm the deletion.

<Frame caption="Select route table to delete, right click, select Delete Route Table and confirm deletion.">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/703f533d-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=c5c73bec79c1516e6301bd40c50b8858" width="2304" height="1828" data-path="images/703f533d-image.jpeg" />
</Frame>

4\) Detach all related internet gateways. Select **Internet Gateways** section in the left menu, select all related internet gateways (usually 1 internet gateway per deployment). Right mouse click or click **Detach from VPC** item in **Actions** menu. Confirm the detachment.

<Frame caption="Select internet gateway to detach, right click, select Detach from VPC and confirm.">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/6ea9d0a8-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=9ebc09bdac2d137297825a62faff211c" width="2304" height="1828" data-path="images/6ea9d0a8-image.jpeg" />
</Frame>

5\) Remove all related DHCP options sets. Select **DHCP Options Sets** section in the left menu, select all related DHCP options sets (usually 1 DHCP option set per deployment). Right mouse click or click **Delete DHCP options** *set* item in **Actions** menu. Confirm the deletion.

<Frame caption="Select DHCP Option Sets, select set, right click, select Delete DHCP options set and confirm">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/3a57ee3e-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=1fe051fcb82355717ece549fb9a2a197" width="2304" height="1448" data-path="images/3a57ee3e-image.jpeg" />
</Frame>

6\) Remove all related Network ACLs. Select **Network ACLs** section in the left menu, select all related Network ACLs (usually 1 Network ACL per deployment). Right mouse click or click **Delete network ACL** item in **Actions** menu. Confirm the deletion.

<Frame caption="Select Network ACLs, select ACL to delete, right click, select Delete network ACL and confirm">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/a54811b7-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=cc2a4b91b821fe05d2d95b51e8484ddb" width="2304" height="1448" data-path="images/a54811b7-image.jpeg" />
</Frame>

7\) Remove all related Security groups. Select **Security Groups** section in the left menu, select all related Security groups (usually 1 Security group for deployment). Right mouse click or click **Delete security group** item in **Actions** menu. Confirm the deletion.

<Frame caption="Go to Security Groups, select security group, right click, select Delete security group, confirm">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/79c13ce4-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=c0cafd62f567860aecc644ec9caabd41" width="2304" height="1448" data-path="images/79c13ce4-image.jpeg" />
</Frame>

8\) Remove all related VPCs. Select **Your VPCs** section in the left menu, select all related VPCs (usually 1 VPC for deployment). Right mouse click or click **Delete VPC** item in **Actions** menu. Confirm the deletion.

<Frame caption="Select Your VPCs, select correct VPC, right click, select Delete VPC and confirm">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/cf228cd8-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=1013694080120ebcb291be25337b2801" width="2304" height="1448" data-path="images/cf228cd8-image.jpeg" />
</Frame>

###

1\) In the Find Services box, type in **RDS** and select.

<Frame caption="Select RDS">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/10b029a9-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=14a642f3ce3bdad9ce1fbb839f420d6c" width="2304" height="1448" data-path="images/10b029a9-image.jpeg" />
</Frame>

2\) Remove all related subnet groups. Select **Subnet groups** section in the left menu, select all related subnet groups (usually 1 subnet group for deployment). Select subnet group and click **Delete** button. Confirm the deletion.

<Frame caption="Go to Subnet Groups, select the subnet to delete, click the Delete button and confirm">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/b089cf35-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=40b71c73ba76ae5e8f6e3d7841d3aee5" width="2304" height="1448" data-path="images/b089cf35-image.jpeg" />
</Frame>

3\) Remove all related RDSs. Select **Databases** section in the left menu, select all related databases (usually 1 database for deployment). Select the Database, go to the **Actions** menu, and select **Delete** from the menu. Confirm the deletion.

<Frame caption="Go to Databases, select the DB to delete, click the Actions menu and select Delete.">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/57836171-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=1f02c3dd8623ab1513b97b96b4dd3221" width="2304" height="1401" data-path="images/57836171-image.jpeg" />
</Frame>

<Tip>
  This instruction was moved from [https://forum.poa.network/t/aws-settings-for-blockscout-terraform-deployment/1962](https://forum.poa.network/t/aws-settings-for-blockscout-terraform-deployment/1962)
</Tip>
