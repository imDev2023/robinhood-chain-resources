Title: Blockscout Smart Contract Verification API - Blockscout

URL Source: https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api

Markdown Content:
> ## Documentation Index
> 
> 
> Fetch the complete documentation index at:[/llms.txt](https://docs.blockscout.com/llms.txt)
> 
> 
> Use this file to discover all available pages before exploring further.

[Skip to main content](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#content-area)

[Blockscout home page![Image 1: light logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/Color_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=7cffdcbb354b1aa090d9f7d3ca4f3452)![Image 2: dark logo](https://mintcdn.com/blockscout/cNJj4Zpe0FBD2sXC/logo/White_BS_logo_hor.svg?fit=max&auto=format&n=cNJj4Zpe0FBD2sXC&q=85&s=79d28502f70131c02702daa820d2345b)](https://www.blockscout.com/)

Search...

⌘K Ask Assistant⌘I

*   [Support](https://discord.gg/blockscout)
*   [blockscout/blockscout](https://github.com/blockscout/blockscout "blockscout/blockscout")
*   [blockscout/blockscout](https://github.com/blockscout/blockscout "blockscout/blockscout")

Search...

Navigation

Verification APIs

Blockscout Smart Contract Verification API

[Guides](https://docs.blockscout.com/)[API Reference](https://docs.blockscout.com/devs/apis)[About Blockscout](https://docs.blockscout.com/about/features)

*   [Community](https://discord.gg/blockscout)
*   [Blog](https://www.blog.blockscout.com/)
*   [API Docs](https://docs.blockscout.com/devs/apis)

### Blockscout APIs

*   [Overview](https://docs.blockscout.com/devs/apis)
*    PRO API  
*   [Dev Portal](https://docs.blockscout.com/devs/dev-portal)
*   [Migrate from Etherscan to Blockscout PRO API](https://docs.blockscout.com/devs/migrate-from-etherscan)
*    Use Cases  

### PRO API Endpoints

*   MultichainDomains  
*   DomainsExtractor  
*   Metadata  
*   ClusterExplorerService  
*   MultichainAggregatorService  
*   legacy  
*   search  
*   addresses  
*   advanced-filters  
*   arbitrum  
*   beacon_deposits  
*   blocks  
*   celo  
*   csv-export  
*   internal-transactions  
*   main-page  
*   optimism  
*   zksync  
*   account-abstraction  
*   scroll  
*   shibarium  
*   smart-contracts  
*   stats  
*   token-transfers  
*   tokens  
*   transactions  
*   stability  
*   zilliqa  
*   withdrawals  
*   StatsService  

### Additional Service APIs

*   [Swagger Hub](https://docs.blockscout.com/devs/apis/swagger-hub)
*   [Autoscout API](https://docs.blockscout.com/devs/apis/autoscout-api)
*    Test Merits APIs  
*    Verification APIs  
    *   [Blockscout Smart Contract Verification API](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api)

## On this page

*   [License type](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#license-type)
*   [Verify smart contract](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verify-smart-contract)
*   [verification service running](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-service-running)
*   [Flattened contract](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#flattened-contract)
    *   [verification flattened contract](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-flattened-contract)

*   [Via Standard JSON input](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#via-standard-json-input)
    *   [verification standard json](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-standard-json)

*   [Via Sourcify Files](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#via-sourcify-files)
    *   [verification sourcify](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-sourcify)

*   [Multi-part Solidity files](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#multi-part-solidity-files)
    *   [verification multipart](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-multipart)

*   [Vyper Contracts](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-contracts)
    *   [verification vyper contract](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-vyper-contract)

*   [Vyper Multi-part files](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-multi-part-files)
    *   [verification multipart vyper](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-multipart-vyper)

*   [Vyper Standard JSON input](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-standard-json-input)
    *   [verification standard json vyper](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-standard-json-vyper)

Verification APIs

# Blockscout Smart Contract Verification API

Copy page Copy page

Use the Blockscout contract verification API to verify Solidity and Vyper smart contracts programmatically with source code, JSON input, or bytecode.

Copy page Copy page

This is the preferred option for contract verification via API. However, you can also use RPC endpoints, [more info is available here](https://docs.blockscout.com/devs/apis/rpc/contract#verify-a-contract-with-its-source-code-and-contract-creation-information).
### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#license-type)

License type

You can specify license type of the smart contract as `string` or `number`. For example for `GNU General Public License v2.0 (GNU GPLv2)` you could pass either `4` or `"gnu_gpl_v2"`We are supporting such types of license as:

```
1. No License (None)
2. The Unlicense (Unlicense)
3. MIT License (MIT)
4. GNU General Public License v2.0 (GNU GPLv2)
5. GNU General Public License v3.0 (GNU GPLv3)
6. GNU Lesser General Public License v2.1 (GNU LGPLv2.1)
7. GNU Lesser General Public License v3.0 (GNU LGPLv3)
8. BSD 2-clause "Simplified" license (BSD-2-Clause)
9. BSD 3-clause "New" Or "Revised" license* (BSD-3-Clause)
10. Mozilla Public License 2.0 (MPL-2.0)
11. Open Software License 3.0 (OSL-3.0)
12. Apache 2.0 (Apache-2.0)
13. GNU Affero General Public License (GNU AGPLv3)
14. Business Source License (BSL 1.1)
```

API license types:

```
none
unlicense
mit
gnu_gpl_v2
gnu_gpl_v3
gnu_lgpl_v2_1
gnu_lgpl_v3
bsd_2_clause
bsd_3_clause
mpl_2_0
osl_3_0
apache_2_0
gnu_agpl_v3
bsl_1_1
```

### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verify-smart-contract)

Verify smart contract

Use the appropriate Blockscout instance endpoint to verify if the smart contract microservice is enabled.In the following examples we use [https://eth.blockscout.com](https://eth.blockscout.com/) to query Ethereum.
### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-service-running)

verification service running

`GET``https://eth.blockscout.com/api/v2/smart-contracts/verification/config`**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
GET /api/v2/smart-contracts/verification/config HTTP/1.1
Host: eth.blockscout.com
Accept: */*
```

```
curl -L \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/verification/config' \
  --header 'Accept: */*'
```

```
const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/verification/config', {
    method: 'GET',
    headers: {
      "Accept": "*/*"
    },
});

const data = await response.json();
```

```
import requests

response = requests.get(
    "https://eth.blockscout.com/api/v2/smart-contracts/verification/config",
    headers={"Accept":"*/*"},
)

data = response.json()
```

200 Successful Response

```
No content
```

`0x` contract addresses in POST example urls below should be replaced with your contract hash supplied on contract creation. Variables in the body are examples and should be replaced with your contract details.

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#flattened-contract)

Flattened contract

For more information on parameters to pass, see the [flattened source code information on the Verifying a smart contract page](https://docs.blockscout.com/devs/verification#via-flattened-source-code).
### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-flattened-contract)

verification flattened contract

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0xb12cad649a56e67188bbaa56583c18dc7d2812ed/verification/via/flattened-code`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-object)

object

Example: `{"compiler_version":"v0.8.17+commit.8df45f5f","license_type":"mit","source_code":"// SPDX-License-Identifier: GPL-3.0\n\npragma solidity >=0.7.0 <0.9.0;\n\n/**\n * @title Owner\n * @dev Set & change owner\n */\ncontract Owner {\n\n address private owner;\n \n // event for EVM logging 2345678ewqwertyui54567890987654345678\n event OwnerSet(address indexed oldOwner, address indexed newOwner);\n \n // modifier to check if caller is owner\n modifier isOwner() {\n // If the first argument of 'require' evaluates to 'false', execution terminates and all\n // changes to the state and to Ether balances are reverted.\n // This used to consume all gas in old EVM versions, but not anymore.\n // It is often a good idea to use 'require' to check if functions are called correctly.\n // As a second argument, you can also provide an explanation about what went wrong.\n require(msg.sender == owner, \"Caller is not owner\");\n _;\n }\n \n /**\n * @dev Set contract deployer as owner\n */\n constructor(uint112 abc, address abb, bytes32 ghnc) {\n // console.log(\"Owner contract deployed by:\", msg.sender);\n owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor\n emit OwnerSet(address(0), owner);\n }\n\n /**\n * @dev Change owner\n * @param newOwner address of new owner\n */\n function changeOwner(address newOwner) public isOwner {\n emit OwnerSet(owner, newOwner);\n owner = newOwner;\n }\n\n /**\n * @dev Return owner address \n * @return address of owner\n */\n function getOwner() external view returns (address) {\n return owner;\n }\n}","is_optimization_enabled":true,"optimization_runs":199,"contract_name":"Owner","libraries":{"Libcheck":"0x030f7c7dbd472864220bcf9e37ede1b8a3125970","Libcheck_1":"0x030f7c7dbd472864220bcf9e37ede1b8a3125970"},"evm_version":"berlin","autodetect_constructor_args":true}`

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0xb12cad649a56e67188bbaa56583c18dc7d2812ed/verification/via/flattened-code HTTP/1.1
Host: eth.blockscout.com
Content-Type: application/json
Accept: */*
Content-Length: 2029

{
  "compiler_version": "v0.8.17+commit.8df45f5f",
  "license_type": "mit",
  "source_code": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity >=0.7.0 <0.9.0;\n\n/**\n * @title Owner\n * @dev Set & change owner\n */\ncontract Owner {\n\n    address private owner;\n    \n    // event for EVM logging 2345678ewqwertyui54567890987654345678\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\n    \n    // modifier to check if caller is owner\n    modifier isOwner() {\n        // If the first argument of 'require' evaluates to 'false', execution terminates and all\n        // changes to the state and to Ether balances are reverted.\n        // This used to consume all gas in old EVM versions, but not anymore.\n        // It is often a good idea to use 'require' to check if functions are called correctly.\n        // As a second argument, you can also provide an explanation about what went wrong.\n        require(msg.sender == owner, \"Caller is not owner\");\n        _;\n    }\n    \n    /**\n     * @dev Set contract deployer as owner\n     */\n    constructor(uint112 abc, address abb, bytes32 ghnc) {\n        // console.log(\"Owner contract deployed by:\", msg.sender);\n        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor\n        emit OwnerSet(address(0), owner);\n    }\n\n    /**\n     * @dev Change owner\n     * @param newOwner address of new owner\n     */\n    function changeOwner(address newOwner) public isOwner {\n        emit OwnerSet(owner, newOwner);\n        owner = newOwner;\n    }\n\n    /**\n     * @dev Return owner address \n     * @return address of owner\n     */\n    function getOwner() external view returns (address) {\n        return owner;\n    }\n}",
  "is_optimization_enabled": true,
  "optimization_runs": 199,
  "contract_name": "Owner",
  "libraries": {
    "Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970",
    "Libcheck_1": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"
  },
  "evm_version": "berlin",
  "autodetect_constructor_args": true
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0xb12cad649a56e67188bbaa56583c18dc7d2812ed/verification/via/flattened-code' \
  --header 'Content-Type: application/json' \
  --data '{
    "compiler_version": "v0.8.17+commit.8df45f5f",
    "license_type": "mit",
    "source_code": "// SPDX-License-Identifier: GPL-3.0

  pragma solidity >=0.7.0 <0.9.0;

  /**
   * @title Owner
   * @dev Set & change owner
   */
  contract Owner {

      address private owner;
      
      // event for EVM logging 2345678ewqwertyui54567890987654345678
      event OwnerSet(address indexed oldOwner, address indexed newOwner);
      
      // modifier to check if caller is owner
      modifier isOwner() {
          // If the first argument of 'require' evaluates to 'false', execution terminates and all
          // changes to the state and to Ether balances are reverted.
          // This used to consume all gas in old EVM versions, but not anymore.
          // It is often a good idea to use 'require' to check if functions are called correctly.
          // As a second argument, you can also provide an explanation about what went wrong.
          require(msg.sender == owner, \"Caller is not owner\");
          _;
      }
      
      /**
       * @dev Set contract deployer as owner
       */
      constructor(uint112 abc, address abb, bytes32 ghnc) {
          // console.log(\"Owner contract deployed by:\", msg.sender);
          owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
          emit OwnerSet(address(0), owner);
      }

      /**
       * @dev Change owner
       * @param newOwner address of new owner
       */
      function changeOwner(address newOwner) public isOwner {
          emit OwnerSet(owner, newOwner);
          owner = newOwner;
      }

      /**
       * @dev Return owner address 
       * @return address of owner
       */
      function getOwner() external view returns (address) {
          return owner;
      }
  }",
    "is_optimization_enabled": true,
    "optimization_runs": 199,
    "contract_name": "Owner",
    "libraries": {
      "Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970",
      "Libcheck_1": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"
    },
    "evm_version": "berlin",
    "autodetect_constructor_args": true
  }'
```

```
const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0xb12cad649a56e67188bbaa56583c18dc7d2812ed/verification/via/flattened-code', {
    method: 'POST',
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      "compiler_version": "v0.8.17+commit.8df45f5f",
      "license_type": "mit",
      "source_code": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity >=0.7.0 <0.9.0;\n\n/**\n * @title Owner\n * @dev Set & change owner\n */\ncontract Owner {\n\n    address private owner;\n    \n    // event for EVM logging 2345678ewqwertyui54567890987654345678\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\n    \n    // modifier to check if caller is owner\n    modifier isOwner() {\n        // If the first argument of 'require' evaluates to 'false', execution terminates and all\n        // changes to the state and to Ether balances are reverted.\n        // This used to consume all gas in old EVM versions, but not anymore.\n        // It is often a good idea to use 'require' to check if functions are called correctly.\n        // As a second argument, you can also provide an explanation about what went wrong.\n        require(msg.sender == owner, \"Caller is not owner\");\n        _;\n    }\n    \n    /**\n     * @dev Set contract deployer as owner\n     */\n    constructor(uint112 abc, address abb, bytes32 ghnc) {\n        // console.log(\"Owner contract deployed by:\", msg.sender);\n        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor\n        emit OwnerSet(address(0), owner);\n    }\n\n    /**\n     * @dev Change owner\n     * @param newOwner address of new owner\n     */\n    function changeOwner(address newOwner) public isOwner {\n        emit OwnerSet(owner, newOwner);\n        owner = newOwner;\n    }\n\n    /**\n     * @dev Return owner address \n     * @return address of owner\n     */\n    function getOwner() external view returns (address) {\n        return owner;\n    }\n}",
      "is_optimization_enabled": true,
      "optimization_runs": 199,
      "contract_name": "Owner",
      "libraries": {
        "Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970",
        "Libcheck_1": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"
      },
      "evm_version": "berlin",
      "autodetect_constructor_args": true
    })
});

const data = await response.json();
```

```
import requests

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0xb12cad649a56e67188bbaa56583c18dc7d2812ed/verification/via/flattened-code",
    headers={"Content-Type":"application/json"},
    data=json.dumps({
      "compiler_version": "v0.8.17+commit.8df45f5f",
      "license_type": "mit",
      "source_code": "// SPDX-License-Identifier: GPL-3.0\n\npragma solidity >=0.7.0 <0.9.0;\n\n/**\n * @title Owner\n * @dev Set & change owner\n */\ncontract Owner {\n\n    address private owner;\n    \n    // event for EVM logging 2345678ewqwertyui54567890987654345678\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\n    \n    // modifier to check if caller is owner\n    modifier isOwner() {\n        // If the first argument of 'require' evaluates to 'false', execution terminates and all\n        // changes to the state and to Ether balances are reverted.\n        // This used to consume all gas in old EVM versions, but not anymore.\n        // It is often a good idea to use 'require' to check if functions are called correctly.\n        // As a second argument, you can also provide an explanation about what went wrong.\n        require(msg.sender == owner, \"Caller is not owner\");\n        _;\n    }\n    \n    /**\n     * @dev Set contract deployer as owner\n     */\n    constructor(uint112 abc, address abb, bytes32 ghnc) {\n        // console.log(\"Owner contract deployed by:\", msg.sender);\n        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor\n        emit OwnerSet(address(0), owner);\n    }\n\n    /**\n     * @dev Change owner\n     * @param newOwner address of new owner\n     */\n    function changeOwner(address newOwner) public isOwner {\n        emit OwnerSet(owner, newOwner);\n        owner = newOwner;\n    }\n\n    /**\n     * @dev Return owner address \n     * @return address of owner\n     */\n    function getOwner() external view returns (address) {\n        return owner;\n    }\n}",
      "is_optimization_enabled": True,
      "optimization_runs": 199,
      "contract_name": "Owner",
      "libraries": {
        "Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970",
        "Libcheck_1": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"
      },
      "evm_version": "berlin",
      "autodetect_constructor_args": True
    })
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#via-standard-json-input)

Via Standard JSON input

For more information on parameters to pass, see the [flattened source code information on the Verifying a smart contract page](https://docs.blockscout.com/devs/verification#via-flattened-source-code). `0x` contract in POST example should be replaced with your contract hash.
### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-standard-json)

verification standard json

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0x9c1c619176b4f8521a0ab166945d785b92aef453/verification/via/standard-input`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-compiler-version)

compiler_version

string

Example: `v0.8.17+commit.8df45f5f`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-contract-name)

contract_name

string

Example: `Owner`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-0)

files[0]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-autodetect-constructor-args)

autodetect_constructor_args

boolean

Example: `false`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-constructor-args)

constructor_args

string

Example: `00000000000000000000000000000000000000000000000000000002d2982db3000000000000000000000000bb36c792b9b45aaf8b848a1392b0d6559202729e666f6f0000000000000000000000000000000000000000000000000000000000`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-license-type)

license_type

string

Example: `gnu_gpl_v2`

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0x9c1c619176b4f8521a0ab166945d785b92aef453/verification/via/standard-input HTTP/1.1
Host: eth.blockscout.com
Content-Type: multipart/form-data
Accept: */*
Content-Length: 370

{
  "compiler_version": "v0.8.17+commit.8df45f5f",
  "contract_name": "Owner",
  "files[0]": "binary",
  "autodetect_constructor_args": "false",
  "constructor_args": "00000000000000000000000000000000000000000000000000000002d2982db3000000000000000000000000bb36c792b9b45aaf8b848a1392b0d6559202729e666f6f0000000000000000000000000000000000000000000000000000000000",
  "license_type": "gnu_gpl_v2"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0x9c1c619176b4f8521a0ab166945d785b92aef453/verification/via/standard-input' \
  --header 'Content-Type: multipart/form-data' \
  --form 'compiler_version=v0.8.17+commit.8df45f5f' \
  --form 'contract_name=Owner' \
  --form 'files[0]=binary' \
  --form 'autodetect_constructor_args=false' \
  --form 'constructor_args=00000000000000000000000000000000000000000000000000000002d2982db3000000000000000000000000bb36c792b9b45aaf8b848a1392b0d6559202729e666f6f0000000000000000000000000000000000000000000000000000000000' \
  --form 'license_type=gnu_gpl_v2'
```

```
const formData = new FormData();

formData.append("compiler_version", "v0.8.17+commit.8df45f5f");
formData.append("contract_name", "Owner");
formData.append("files[0]", "binary");
formData.append("autodetect_constructor_args", "false");
formData.append("constructor_args", "00000000000000000000000000000000000000000000000000000002d2982db3000000000000000000000000bb36c792b9b45aaf8b848a1392b0d6559202729e666f6f0000000000000000000000000000000000000000000000000000000000");
formData.append("license_type", "gnu_gpl_v2");

const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0x9c1c619176b4f8521a0ab166945d785b92aef453/verification/via/standard-input', {
    method: 'POST',
    headers: {
      "Content-Type": "multipart/form-data"
    },
    body: formData
});

const data = await response.json();
```

```
import requests

files = {
    "compiler_version": "v0.8.17+commit.8df45f5f",
    "contract_name": "Owner",
    "files[0]": "binary",
    "autodetect_constructor_args": "false",
    "constructor_args": "00000000000000000000000000000000000000000000000000000002d2982db3000000000000000000000000bb36c792b9b45aaf8b848a1392b0d6559202729e666f6f0000000000000000000000000000000000000000000000000000000000",
    "license_type": "gnu_gpl_v2",
}

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0x9c1c619176b4f8521a0ab166945d785b92aef453/verification/via/standard-input",
    headers={"Content-Type":"multipart/form-data"},
    files=files
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#via-sourcify-files)

Via Sourcify Files

For more information on parameters to pass, see the [Contract Verification via Sourcify](https://docs.blockscout.com/devs/verification/contracts-verification-via-sourcify). `0x` contract in POST example url should be replaced with your contract hash, as should your relevant variables.
### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-sourcify)

verification sourcify

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/sourcify`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-0-1)

files[0]

string

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-chosen-contract-index)

chosen_contract_index

integer

Example: `4`

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/sourcify HTTP/1.1
Host: eth.blockscout.com
Content-Type: multipart/form-data
Accept: */*
Content-Length: 47

{
  "files[0]": "text",
  "chosen_contract_index": "4"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/sourcify' \
  --header 'Content-Type: multipart/form-data' \
  --form 'files[0]=text' \
  --form 'chosen_contract_index=4'
```

```
const formData = new FormData();

formData.append("files[0]", "text");
formData.append("chosen_contract_index", "4");

const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/sourcify', {
    method: 'POST',
    headers: {
      "Content-Type": "multipart/form-data"
    },
    body: formData
});

const data = await response.json();
```

```
import requests

files = {
    "files[0]": "text",
    "chosen_contract_index": "4",
}

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/sourcify",
    headers={"Content-Type":"multipart/form-data"},
    files=files
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#multi-part-solidity-files)

Multi-part Solidity files

### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-multipart)

verification multipart

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/multi-part`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-compiler-version-1)

compiler_version

number

Example: `v0.8.17+commit.8df45f5f`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-license-type-1)

license_type

string

Example: `gnu_gpl_v3`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-is-optimization-enabled)

is_optimization_enabled

boolean

Example: `true`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-libraries)

libraries

string

Example: `{"Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"}`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-evm-version)

evm_version

string

Example: `london`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-optimization-runs)

optimization_runs

integer

Example: `199`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-0-2)

files[0]

string

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-1)

files[1]

string . binary

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/multi-part HTTP/1.1
Host: eth.blockscout.com
Content-Type: multipart/form-data
Accept: */*
Content-Length: 271

{
  "compiler_version": "v0.8.17+commit.8df45f5f",
  "license_type": "gnu_gpl_v3",
  "is_optimization_enabled": true,
  "libraries": "{\"Libcheck\": \"0x030f7c7dbd472864220bcf9e37ede1b8a3125970\"}",
  "evm_version": "london",
  "optimization_runs": 199,
  "files[0]": "text",
  "files[1]": "binary"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/multi-part' \
  --header 'Content-Type: multipart/form-data' \
  --form 'compiler_version=v0.8.17+commit.8df45f5f' \
  --form 'license_type=gnu_gpl_v3' \
  --form 'is_optimization_enabled=true' \
  --form 'libraries={"Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"}' \
  --form 'evm_version=london' \
  --form 'optimization_runs=199' \
  --form 'files[0]=text' \
  --form 'files[1]=binary'
```

```
const formData = new FormData();

formData.append("compiler_version", "v0.8.17+commit.8df45f5f");
formData.append("license_type", "gnu_gpl_v3");
formData.append("is_optimization_enabled", "true");
formData.append("libraries", "{\"Libcheck\": \"0x030f7c7dbd472864220bcf9e37ede1b8a3125970\"}");
formData.append("evm_version", "london");
formData.append("optimization_runs", "199");
formData.append("files[0]", "text");
formData.append("files[1]", "binary");

const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/multi-part', {
    method: 'POST',
    headers: {
      "Content-Type": "multipart/form-data"
    },
    body: formData
});

const data = await response.json();
```

```
import requests

files = {
    "compiler_version": "v0.8.17+commit.8df45f5f",
    "license_type": "gnu_gpl_v3",
    "is_optimization_enabled": "true",
    "libraries": "{"Libcheck": "0x030f7c7dbd472864220bcf9e37ede1b8a3125970"}",
    "evm_version": "london",
    "optimization_runs": "199",
    "files[0]": "text",
    "files[1]": "binary",
}

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0x030f7c7dbd472864220bcf9e37ede1b8a3125970/verification/via/multi-part",
    headers={"Content-Type":"multipart/form-data"},
    files=files
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-contracts)

Vyper Contracts

### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-vyper-contract)

verification vyper contract

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0xd73249995040f04cb891bdf0f997579ee3a6676c/verification/via/vyper-code`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-object-1)

object

Example: `{"compiler_version":"v0.2.12+commit.2c6842c","license_type":"gnu_agpl_v3","source_code":"from vyper.interfaces import ERC20\n\nimplements: ERC20\n\nevent Transfer:\n    sender: indexed(address)\n    receiver: indexed(address)\n    value: uint256\n\nevent Approval:\n    owner: indexed(address)\n    spender: indexed(address)\n    value: uint256\n\nname: public(String[64])\nsymbol: public(String[32])\ndecimals: public(uint256)\n\nbalanceOf: public(HashMap[address, uint256])\nallowance: public(HashMap[address, HashMap[address, uint256]])\ntotalSupply: public(uint256)\nminter: address\n_supply: uint256\n_check: uint256 #1% of the total supply check\n\n\n@external\ndef __init__():\n    self._supply = 10_000_000_000 \n    self._check = 100_000_000\n    self.decimals = 18\n    self.name = 'Kooopa'\n    self.symbol = 'KOO'\n    \n    init_supply: uint256 = self._supply * 10 ** self.decimals\n    \n    self.balanceOf[msg.sender] = init_supply\n    self.totalSupply = init_supply\n    self.minter = msg.sender\n\n    log Transfer(ZERO_ADDRESS, msg.sender, init_supply)\n\n\n@internal\ndef _transfer(_from : address, _to : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Transfer limit of 1%(100 Million) Tokens'\n\n    TargetBalance: uint256 = self.balanceOf[_to] + _value\n    assert TargetBalance <= self._check, 'Single wallet cannot hold more than 1%(100 Million) Tokens'\n\n    self.balanceOf[_from] -= _value\n    self.balanceOf[_to] += _value\n    log Transfer(_from, _to, _value)\n    return True\n\n\n@external\ndef transfer(_to : address, _value : uint256) -> bool:\n    self._transfer(msg.sender, _to, _value)\n    return True\n\n\n@external\ndef transferFrom(_from : address, _to : address, _value : uint256) -> bool:\n    self._transfer(_from, _to, _value)\n    self.allowance[_from][msg.sender] -= _value\n    return True\n\n\n@external\ndef approve(_spender : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Cant Approve more than 1%(100 Million) Tokens for transfer'\n\n    self.allowance[msg.sender][_spender] = _value\n    log Approval(msg.sender, _spender, _value)\n    return True\n\n\n@external\ndef mint(_to: address, _value: uint256):\n    assert msg.sender == self.minter\n    assert _to != ZERO_ADDRESS\n    self.totalSupply += _value\n    self.balanceOf[_to] += _value\n    log Transfer(ZERO_ADDRESS, _to, _value)\n\n\n@internal\ndef _burn(_to: address, _value: uint256):\n    \n    assert _to != ZERO_ADDRESS\n    self.totalSupply -= _value\n    self.balanceOf[_to] -= _value\n    log Transfer(_to, ZERO_ADDRESS, _value)\n\n\n@external\ndef burn(_value: uint256):\n    self._burn(msg.sender, _value)\n\n\n@external\ndef burnFrom(_to: address, _value: uint256):\n    self.allowance[_to][msg.sender] -= _value\n    self._burn(_to, _value)","constructor_args":null,"contract_name":"Storage","evm_version":"istanbul"}`

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0xd73249995040f04cb891bdf0f997579ee3a6676c/verification/via/vyper-code HTTP/1.1
Host: eth.blockscout.com
Content-Type: application/json
Accept: */*
Content-Length: 2891

{
  "compiler_version": "v0.2.12+commit.2c6842c",
  "license_type": "gnu_agpl_v3",
  "source_code": "from vyper.interfaces import ERC20\n\nimplements: ERC20\n\nevent Transfer:\n    sender: indexed(address)\n    receiver: indexed(address)\n    value: uint256\n\nevent Approval:\n    owner: indexed(address)\n    spender: indexed(address)\n    value: uint256\n\nname: public(String[64])\nsymbol: public(String[32])\ndecimals: public(uint256)\n\nbalanceOf: public(HashMap[address, uint256])\nallowance: public(HashMap[address, HashMap[address, uint256]])\ntotalSupply: public(uint256)\nminter: address\n_supply: uint256\n_check: uint256 #1% of the total supply check\n\n\n@external\ndef __init__():\n    self._supply = 10_000_000_000 \n    self._check = 100_000_000\n    self.decimals = 18\n    self.name = 'Kooopa'\n    self.symbol = 'KOO'\n    \n    init_supply: uint256 = self._supply * 10 ** self.decimals\n    \n    self.balanceOf[msg.sender] = init_supply\n    self.totalSupply = init_supply\n    self.minter = msg.sender\n\n    log Transfer(ZERO_ADDRESS, msg.sender, init_supply)\n\n\n@internal\ndef _transfer(_from : address, _to : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Transfer limit of 1%(100 Million) Tokens'\n\n    TargetBalance: uint256 = self.balanceOf[_to] + _value\n    assert TargetBalance <= self._check, 'Single wallet cannot hold more than 1%(100 Million) Tokens'\n\n    self.balanceOf[_from] -= _value\n    self.balanceOf[_to] += _value\n    log Transfer(_from, _to, _value)\n    return True\n\n\n@external\ndef transfer(_to : address, _value : uint256) -> bool:\n    self._transfer(msg.sender, _to, _value)\n    return True\n\n\n@external\ndef transferFrom(_from : address, _to : address, _value : uint256) -> bool:\n    self._transfer(_from, _to, _value)\n    self.allowance[_from][msg.sender] -= _value\n    return True\n\n\n@external\ndef approve(_spender : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Cant Approve more than 1%(100 Million) Tokens for transfer'\n\n    self.allowance[msg.sender][_spender] = _value\n    log Approval(msg.sender, _spender, _value)\n    return True\n\n\n@external\ndef mint(_to: address, _value: uint256):\n    assert msg.sender == self.minter\n    assert _to != ZERO_ADDRESS\n    self.totalSupply += _value\n    self.balanceOf[_to] += _value\n    log Transfer(ZERO_ADDRESS, _to, _value)\n\n\n@internal\ndef _burn(_to: address, _value: uint256):\n    \n    assert _to != ZERO_ADDRESS\n    self.totalSupply -= _value\n    self.balanceOf[_to] -= _value\n    log Transfer(_to, ZERO_ADDRESS, _value)\n\n\n@external\ndef burn(_value: uint256):\n    self._burn(msg.sender, _value)\n\n\n@external\ndef burnFrom(_to: address, _value: uint256):\n    self.allowance[_to][msg.sender] -= _value\n    self._burn(_to, _value)",
  "constructor_args": null,
  "contract_name": "Storage",
  "evm_version": "istanbul"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0xd73249995040f04cb891bdf0f997579ee3a6676c/verification/via/vyper-code' \
  --header 'Content-Type: application/json' \
  --data '{
    "compiler_version": "v0.2.12+commit.2c6842c",
    "license_type": "gnu_agpl_v3",
    "source_code": "from vyper.interfaces import ERC20

  implements: ERC20

  event Transfer:
      sender: indexed(address)
      receiver: indexed(address)
      value: uint256

  event Approval:
      owner: indexed(address)
      spender: indexed(address)
      value: uint256

  name: public(String[64])
  symbol: public(String[32])
  decimals: public(uint256)

  balanceOf: public(HashMap[address, uint256])
  allowance: public(HashMap[address, HashMap[address, uint256]])
  totalSupply: public(uint256)
  minter: address
  _supply: uint256
  _check: uint256 #1% of the total supply check

  @external
  def __init__():
      self._supply = 10_000_000_000 
      self._check = 100_000_000
      self.decimals = 18
      self.name = 'Kooopa'
      self.symbol = 'KOO'
      
      init_supply: uint256 = self._supply * 10 ** self.decimals
      
      self.balanceOf[msg.sender] = init_supply
      self.totalSupply = init_supply
      self.minter = msg.sender

      log Transfer(ZERO_ADDRESS, msg.sender, init_supply)

  @internal
  def _transfer(_from : address, _to : address, _value : uint256) -> bool:
      assert _value <= self._check, 'Transfer limit of 1%(100 Million) Tokens'

      TargetBalance: uint256 = self.balanceOf[_to] + _value
      assert TargetBalance <= self._check, 'Single wallet cannot hold more than 1%(100 Million) Tokens'

      self.balanceOf[_from] -= _value
      self.balanceOf[_to] += _value
      log Transfer(_from, _to, _value)
      return True

  @external
  def transfer(_to : address, _value : uint256) -> bool:
      self._transfer(msg.sender, _to, _value)
      return True

  @external
  def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
      self._transfer(_from, _to, _value)
      self.allowance[_from][msg.sender] -= _value
      return True

  @external
  def approve(_spender : address, _value : uint256) -> bool:
      assert _value <= self._check, 'Cant Approve more than 1%(100 Million) Tokens for transfer'

      self.allowance[msg.sender][_spender] = _value
      log Approval(msg.sender, _spender, _value)
      return True

  @external
  def mint(_to: address, _value: uint256):
      assert msg.sender == self.minter
      assert _to != ZERO_ADDRESS
      self.totalSupply += _value
      self.balanceOf[_to] += _value
      log Transfer(ZERO_ADDRESS, _to, _value)

  @internal
  def _burn(_to: address, _value: uint256):
      
      assert _to != ZERO_ADDRESS
      self.totalSupply -= _value
      self.balanceOf[_to] -= _value
      log Transfer(_to, ZERO_ADDRESS, _value)

  @external
  def burn(_value: uint256):
      self._burn(msg.sender, _value)

  @external
  def burnFrom(_to: address, _value: uint256):
      self.allowance[_to][msg.sender] -= _value
      self._burn(_to, _value)",
    "constructor_args": null,
    "contract_name": "Storage",
    "evm_version": "istanbul"
  }'
```

```
const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0xd73249995040f04cb891bdf0f997579ee3a6676c/verification/via/vyper-code', {
    method: 'POST',
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      "compiler_version": "v0.2.12+commit.2c6842c",
      "license_type": "gnu_agpl_v3",
      "source_code": "from vyper.interfaces import ERC20\n\nimplements: ERC20\n\nevent Transfer:\n    sender: indexed(address)\n    receiver: indexed(address)\n    value: uint256\n\nevent Approval:\n    owner: indexed(address)\n    spender: indexed(address)\n    value: uint256\n\nname: public(String[64])\nsymbol: public(String[32])\ndecimals: public(uint256)\n\nbalanceOf: public(HashMap[address, uint256])\nallowance: public(HashMap[address, HashMap[address, uint256]])\ntotalSupply: public(uint256)\nminter: address\n_supply: uint256\n_check: uint256 #1% of the total supply check\n\n\n@external\ndef __init__():\n    self._supply = 10_000_000_000 \n    self._check = 100_000_000\n    self.decimals = 18\n    self.name = 'Kooopa'\n    self.symbol = 'KOO'\n    \n    init_supply: uint256 = self._supply * 10 ** self.decimals\n    \n    self.balanceOf[msg.sender] = init_supply\n    self.totalSupply = init_supply\n    self.minter = msg.sender\n\n    log Transfer(ZERO_ADDRESS, msg.sender, init_supply)\n\n\n@internal\ndef _transfer(_from : address, _to : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Transfer limit of 1%(100 Million) Tokens'\n\n    TargetBalance: uint256 = self.balanceOf[_to] + _value\n    assert TargetBalance <= self._check, 'Single wallet cannot hold more than 1%(100 Million) Tokens'\n\n    self.balanceOf[_from] -= _value\n    self.balanceOf[_to] += _value\n    log Transfer(_from, _to, _value)\n    return True\n\n\n@external\ndef transfer(_to : address, _value : uint256) -> bool:\n    self._transfer(msg.sender, _to, _value)\n    return True\n\n\n@external\ndef transferFrom(_from : address, _to : address, _value : uint256) -> bool:\n    self._transfer(_from, _to, _value)\n    self.allowance[_from][msg.sender] -= _value\n    return True\n\n\n@external\ndef approve(_spender : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Cant Approve more than 1%(100 Million) Tokens for transfer'\n\n    self.allowance[msg.sender][_spender] = _value\n    log Approval(msg.sender, _spender, _value)\n    return True\n\n\n@external\ndef mint(_to: address, _value: uint256):\n    assert msg.sender == self.minter\n    assert _to != ZERO_ADDRESS\n    self.totalSupply += _value\n    self.balanceOf[_to] += _value\n    log Transfer(ZERO_ADDRESS, _to, _value)\n\n\n@internal\ndef _burn(_to: address, _value: uint256):\n    \n    assert _to != ZERO_ADDRESS\n    self.totalSupply -= _value\n    self.balanceOf[_to] -= _value\n    log Transfer(_to, ZERO_ADDRESS, _value)\n\n\n@external\ndef burn(_value: uint256):\n    self._burn(msg.sender, _value)\n\n\n@external\ndef burnFrom(_to: address, _value: uint256):\n    self.allowance[_to][msg.sender] -= _value\n    self._burn(_to, _value)",
      "constructor_args": null,
      "contract_name": "Storage",
      "evm_version": "istanbul"
    })
});

const data = await response.json();
```

```
import requests

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0xd73249995040f04cb891bdf0f997579ee3a6676c/verification/via/vyper-code",
    headers={"Content-Type":"application/json"},
    data=json.dumps({
      "compiler_version": "v0.2.12+commit.2c6842c",
      "license_type": "gnu_agpl_v3",
      "source_code": "from vyper.interfaces import ERC20\n\nimplements: ERC20\n\nevent Transfer:\n    sender: indexed(address)\n    receiver: indexed(address)\n    value: uint256\n\nevent Approval:\n    owner: indexed(address)\n    spender: indexed(address)\n    value: uint256\n\nname: public(String[64])\nsymbol: public(String[32])\ndecimals: public(uint256)\n\nbalanceOf: public(HashMap[address, uint256])\nallowance: public(HashMap[address, HashMap[address, uint256]])\ntotalSupply: public(uint256)\nminter: address\n_supply: uint256\n_check: uint256 #1% of the total supply check\n\n\n@external\ndef __init__():\n    self._supply = 10_000_000_000 \n    self._check = 100_000_000\n    self.decimals = 18\n    self.name = 'Kooopa'\n    self.symbol = 'KOO'\n    \n    init_supply: uint256 = self._supply * 10 ** self.decimals\n    \n    self.balanceOf[msg.sender] = init_supply\n    self.totalSupply = init_supply\n    self.minter = msg.sender\n\n    log Transfer(ZERO_ADDRESS, msg.sender, init_supply)\n\n\n@internal\ndef _transfer(_from : address, _to : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Transfer limit of 1%(100 Million) Tokens'\n\n    TargetBalance: uint256 = self.balanceOf[_to] + _value\n    assert TargetBalance <= self._check, 'Single wallet cannot hold more than 1%(100 Million) Tokens'\n\n    self.balanceOf[_from] -= _value\n    self.balanceOf[_to] += _value\n    log Transfer(_from, _to, _value)\n    return True\n\n\n@external\ndef transfer(_to : address, _value : uint256) -> bool:\n    self._transfer(msg.sender, _to, _value)\n    return True\n\n\n@external\ndef transferFrom(_from : address, _to : address, _value : uint256) -> bool:\n    self._transfer(_from, _to, _value)\n    self.allowance[_from][msg.sender] -= _value\n    return True\n\n\n@external\ndef approve(_spender : address, _value : uint256) -> bool:\n    assert _value <= self._check, 'Cant Approve more than 1%(100 Million) Tokens for transfer'\n\n    self.allowance[msg.sender][_spender] = _value\n    log Approval(msg.sender, _spender, _value)\n    return True\n\n\n@external\ndef mint(_to: address, _value: uint256):\n    assert msg.sender == self.minter\n    assert _to != ZERO_ADDRESS\n    self.totalSupply += _value\n    self.balanceOf[_to] += _value\n    log Transfer(ZERO_ADDRESS, _to, _value)\n\n\n@internal\ndef _burn(_to: address, _value: uint256):\n    \n    assert _to != ZERO_ADDRESS\n    self.totalSupply -= _value\n    self.balanceOf[_to] -= _value\n    log Transfer(_to, ZERO_ADDRESS, _value)\n\n\n@external\ndef burn(_value: uint256):\n    self._burn(msg.sender, _value)\n\n\n@external\ndef burnFrom(_to: address, _value: uint256):\n    self.allowance[_to][msg.sender] -= _value\n    self._burn(_to, _value)",
      "constructor_args": None,
      "contract_name": "Storage",
      "evm_version": "istanbul"
    })
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-multi-part-files)

Vyper Multi-part files

### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-multipart-vyper)

verification multipart vyper

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-multi-part`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-compiler-version-2)

compiler_version

number

Example: `v0.3.7+commit.6020b8bb`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-license-type-2)

license_type

string

Example: `gnu_lgpl_v2_1`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-evm-version-1)

evm_version

string

Example: `istanbul`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-0-3)

files[0]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-1-1)

files[1]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-interfaces-0)

interfaces[0]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-interfaces-1)

interfaces[1]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-interfaces-2)

interfaces[2]

string . binary

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-multi-part HTTP/1.1
Host: eth.blockscout.com
Content-Type: multipart/form-data
Accept: */*
Content-Length: 216

{
  "compiler_version": "v0.3.7+commit.6020b8bb",
  "license_type": "gnu_lgpl_v2_1",
  "evm_version": "istanbul",
  "files[0]": "binary",
  "files[1]": "binary",
  "interfaces[0]": "binary",
  "interfaces[1]": "binary",
  "interfaces[2]": "binary"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-multi-part' \
  --header 'Content-Type: multipart/form-data' \
  --form 'compiler_version=v0.3.7+commit.6020b8bb' \
  --form 'license_type=gnu_lgpl_v2_1' \
  --form 'evm_version=istanbul' \
  --form 'files[0]=binary' \
  --form 'files[1]=binary' \
  --form 'interfaces[0]=binary' \
  --form 'interfaces[1]=binary' \
  --form 'interfaces[2]=binary'
```

```
const formData = new FormData();

formData.append("compiler_version", "v0.3.7+commit.6020b8bb");
formData.append("license_type", "gnu_lgpl_v2_1");
formData.append("evm_version", "istanbul");
formData.append("files[0]", "binary");
formData.append("files[1]", "binary");
formData.append("interfaces[0]", "binary");
formData.append("interfaces[1]", "binary");
formData.append("interfaces[2]", "binary");

const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-multi-part', {
    method: 'POST',
    headers: {
      "Content-Type": "multipart/form-data"
    },
    body: formData
});

const data = await response.json();
```

```
import requests

files = {
    "compiler_version": "v0.3.7+commit.6020b8bb",
    "license_type": "gnu_lgpl_v2_1",
    "evm_version": "istanbul",
    "files[0]": "binary",
    "files[1]": "binary",
    "interfaces[0]": "binary",
    "interfaces[1]": "binary",
    "interfaces[2]": "binary",
}

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-multi-part",
    headers={"Content-Type":"multipart/form-data"},
    files=files
)

data = response.json()
```

200 Successful Response

```
No content
```

## [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#vyper-standard-json-input)

Vyper Standard JSON input

### [​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#verification-standard-json-vyper)

verification standard json vyper

`POST``https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-standard-input`**Body**

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-compiler-version-3)

compiler_version

number

Example: `v0.2.7+commit.0b3f3b3`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-license-type-3)

license_type

string

Example: `gnu_lgpl_v3`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-evm-version-2)

evm_version

string

Example: `istanbul`

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-0-4)

files[0]

string . binary

[​](https://docs.blockscout.com/devs/verification/blockscout-smart-contract-verification-api#param-files-1-2)

files[1]

string . binary

**Responses**

200 Successful response

HTTP

cURL

JavaScript

Python

```
POST /api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-standard-input HTTP/1.1
Host: eth.blockscout.com
Content-Type: multipart/form-data
Accept: */*
Content-Length: 138

{
  "compiler_version": "v0.2.7+commit.0b3f3b3",
  "license_type": "gnu_lgpl_v3",
  "evm_version": "istanbul",
  "files[0]": "binary",
  "files[1]": "binary"
}
```

```
curl -L \
  --request POST \
  --url 'https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-standard-input' \
  --header 'Content-Type: multipart/form-data' \
  --form 'compiler_version=v0.2.7+commit.0b3f3b3' \
  --form 'license_type=gnu_lgpl_v3' \
  --form 'evm_version=istanbul' \
  --form 'files[0]=binary' \
  --form 'files[1]=binary'
```

```
const formData = new FormData();

formData.append("compiler_version", "v0.2.7+commit.0b3f3b3");
formData.append("license_type", "gnu_lgpl_v3");
formData.append("evm_version", "istanbul");
formData.append("files[0]", "binary");
formData.append("files[1]", "binary");

const response = await fetch('https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-standard-input', {
    method: 'POST',
    headers: {
      "Content-Type": "multipart/form-data"
    },
    body: formData
});

const data = await response.json();
```

```
import requests

files = {
    "compiler_version": "v0.2.7+commit.0b3f3b3",
    "license_type": "gnu_lgpl_v3",
    "evm_version": "istanbul",
    "files[0]": "binary",
    "files[1]": "binary",
}

response = requests.post(
    "https://eth.blockscout.com/api/v2/smart-contracts/0xc3fd3c09d5481f4d6c85e70775804de4c93fe630/verification/via/vyper-standard-input",
    headers={"Content-Type":"multipart/form-data"},
    files=files
)

data = response.json()
```

200 Successful Response

```
No content
```

Was this page helpful?

Yes No

[Post adminapiv1users code Previous](https://docs.blockscout.com/api-reference/pointsadminservice/post-adminapiv1users-code)

[github](https://github.com/blockscout/blockscout)[telegram](https://t.me/blockscoutcommunity)[discord](https://discord.gg/blockscout)[x](https://x.com/blockscout)

[Powered by This documentation is built and hosted on Mintlify, a developer documentation platform](https://www.mintlify.com/?utm_campaign=poweredBy&utm_medium=referral&utm_source=blockscout)

Assistant

Responses are generated using AI and may contain mistakes.
