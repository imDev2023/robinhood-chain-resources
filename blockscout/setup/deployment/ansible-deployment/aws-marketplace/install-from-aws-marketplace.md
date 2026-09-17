> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Install Blockscout from AWS Marketplace Listing

> Step-by-step guide to launching Blockscout from the AWS Marketplace using CloudFormation, including stack parameters, Cognito login, and DNS setup.

<Info>
  Before you start, make sure you have completed the [prerequisites](/setup/deployment/ansible-deployment/aws-marketplace/aws-marketplace-installation).
</Info>

1\) Login to your aws account

2\) Go to [https://aws.amazon.com/marketplace/search/results](https://aws.amazon.com/marketplace/search/results) and search for BlockScout. Click on **BlockScout Blockchain Explorer** to view.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/4ca742de-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=fc68e07a7fef15e7dcf5042d3c8b8500" width="2304" height="1394" data-path="images/4ca742de-image.jpeg" />
</Frame>

3\) From the main BlockScout Page, click the **Continue to** **Subscribe** button (The parameters should be set and do not require any changes)

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/676b0266-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=ac9717740138867f31fae2928b78d1a6" width="2304" height="1425" data-path="images/676b0266-image.jpeg" />
</Frame>

4\) Click **Continue to Configuration**.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/2409a6a6-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=9d1a564795a84d27631fd92e5e391b20" width="2304" height="1240" data-path="images/2409a6a6-image.jpeg" />
</Frame>

5\) Select BlockScout BlockChain Explorer as Fulfillment option and Software Version 3 (both should be selected by default) and **Continue to Launch**.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/fdf1728b-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=a09402e4a89b97823b599afda91581aa" width="2304" height="1383" data-path="images/fdf1728b-image.jpeg" />
</Frame>

6\) Select **Launch CloudFormation** in the Choose Action dropdown, and click **Launch**.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/4e98f371-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=5122f1f12632f550843ff97b611da61e" width="2304" height="1383" data-path="images/4e98f371-image.jpeg" />
</Frame>

7\) Start to configure the stack. Maintain the default selections (Template is ready) and click **Next**.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/f9cf5375-image.jpeg?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=1b983e1155e07500a220ecb08563e920" width="2304" height="1333" data-path="images/f9cf5375-image.jpeg" />
</Frame>

8\) Specify the stack details. Parameters filled in by default can generally be left as-is. For blank items, enter the [chain parameters and environment variables to setup your BlockScout Instance](/setup/deployment/ansible-deployment/aws-marketplace/aws-marketplace-installation#installation-parameters).

<Frame caption="Click next once all parameters are entered">
  <img src="https://mintcdn.com/blockscout/5j9ATJZuQuk5LMJq/images/407c2a71-image.jpeg?fit=max&auto=format&n=5j9ATJZuQuk5LMJq&q=85&s=889ca2aaf85f1bb706839434a3dcc6d6" width="2304" height="1405" data-path="images/407c2a71-image.jpeg" />
</Frame>

9\) Add any optional items.

* [Resource Tags](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-resource-tags.html?icmpid=docs_cfn_console)
* [Permissions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html?icmpid=docs_cfn_console)
* [Advanced Stack Options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html?icmpid=docs_cfn_console)

<Frame caption="Click Next after filling in any additional options">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/5c12146b-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=b7a67b165799fb0dede74df350d572e4" width="2304" height="1369" data-path="images/5c12146b-image.jpeg" />
</Frame>

10\) Review all the parameters. If everything looks good, acknowledge that CloudFormation might create IAM resources and click **Create stack.**

<Info>
  If any items do not match template specifics, you can fix by clicking previous, changing an item, and returning to the Create stack page.
</Info>

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/BBa8nQTQ6isU0DUJ/images/985fead4-image.jpeg?fit=max&auto=format&n=BBa8nQTQ6isU0DUJ&q=85&s=359393443abf6044ec03e915ee07920b" width="2304" height="1198" data-path="images/985fead4-image.jpeg" />
</Frame>

11\) Your instance will be located in the CloudFormation section of AWS (search CloudFormation under services to find). You can manage the stack here, including monitoring processes, updating and deleting.

<Frame caption="Instance creation in CloudFormation">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/b93d8bec-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=e816a65fede4ff4ef8c9687b80e2039a" width="2304" height="1277" data-path="images/b93d8bec-image.jpeg" />
</Frame>

12\) When creation is complete, go to the Outputs tab to find the DNS value. Copy and paste into a browser.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/JTppjXqh5Q4u166M/images/03693717-image.jpeg?fit=max&auto=format&n=JTppjXqh5Q4u166M&q=85&s=9f53918c79c493734eeed583453a2125" width="2304" height="1330" data-path="images/03693717-image.jpeg" />
</Frame>

13\) Enter the username and password from the email you received during setup (email sent to value entered for **CognitoUserEmail** parameter)

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/b8801799-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=23b916f0686a4d6ad389ec4f58ef6f03" width="2304" height="1143" data-path="images/b8801799-image.jpeg" />
</Frame>

14\) You will be asked to change your password. Store in a safe place.

<Frame caption="">
  <img src="https://mintcdn.com/blockscout/kl-dO7vK6d_hNvHA/images/d2a58226-image.jpeg?fit=max&auto=format&n=kl-dO7vK6d_hNvHA&q=85&s=14bc4c7f301a67929dc3e42cc8d3e9ca" width="2304" height="1143" data-path="images/d2a58226-image.jpeg" />
</Frame>

15\) You should now see your BlockScout instance! Depending on the chain you are running, it may take some time to index the data.

<Frame caption="A brand new instance of BlockScout starting to index">
  <img src="https://mintcdn.com/blockscout/9uuzTGHWzjbW9Lu3/images/595d6a15-image.jpeg?fit=max&auto=format&n=9uuzTGHWzjbW9Lu3&q=85&s=d0df2ae8665275c3cd248d5123f96155" width="2304" height="1143" data-path="images/595d6a15-image.jpeg" />
</Frame>

For additional configuration options, see:

* [Customizing CSS](/setup/deployment/ansible-deployment/aws-marketplace/customizing-css)
* [Updating BlockScout on AWS](/setup/deployment/ansible-deployment/aws-marketplace/updating-and-redeploying-in-aws)

***

***
