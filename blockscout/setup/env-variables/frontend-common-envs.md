> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Frontend ENVs: Common

> Overview of common Blockscout frontend environment variables used to customize explorer UI, features, and container runtime settings.

<Info>
  * [Full ENV List](/setup/env-variables/frontend-common-envs/envs) with example values and requirements
  * [**ENV File**](https://github.com/blockscout/frontend/blob/main/configs/envs/.env.eth) example
</Info>

Customize the UI of your running app instance (for example, homepage appearance, sidebar menu, and links in the footer) or enable certain features (like “My account”, “Marketplace”, “Blockchain interaction”, etc) by passing additional variables to your front-end container. These can be passed during runtime, added to the docker container in the `environment:` list, or changed within the `.env` file.
