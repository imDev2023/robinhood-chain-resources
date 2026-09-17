# Bags - Set Up a TypeScript & Node.js Project

> Source: https://docs.bags.fm/how-to-guides/typescript-node-setup
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/typescript-node-setup.md)

---

# Set Up a TypeScript & Node.js Project

> Follow these steps to set up a TypeScript and Node.js project for interacting with the Bags API.

Before you can follow our TypeScript and Node.js how-to guides, you need to set up your development environment. This guide will walk you through creating a new project, installing essential packages, and configuring your environment.

## 1. Initialize Your TypeScript Project

First, create a new directory for your project and initialize it:

```bash theme={null}
mkdir my-bags-project
cd my-bags-project
npm init -y
```

Next, install TypeScript and initialize the TypeScript configuration:

```bash theme={null}
npm install -g typescript
npx tsc --init
```

This will create a `tsconfig.json` file with default settings, which you can customize as needed.

## 2. Install Core Dependencies

Now, install the core dependencies required for most interactions with the Bags API and for running your TypeScript code with Node.js.

```bash theme={null}
npm install @bagsfm/bags-sdk dotenv @solana/web3.js bs58
```

Also, install the necessary development dependencies:

```bash theme={null}
npm install -D typescript ts-node @types/node
```

## 3. Set Up Environment Variables

Create a `.env` file in your project root to store your Bags API key, Solana RPC URL, and other secrets:

```bash theme={null}
# .env
BAGS_API_KEY=your_api_key_here
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
# PRIVATE_KEY=your_base58_encoded_private_key_here  # Required for guides that perform transactions
```

You can get your API key from [dev.bags.fm](https://dev.bags.fm). Some guides might require additional variables like your wallet's private key for signing transactions.

<Warning>
  Never commit your `.env` file to version control. Add it to your `.gitignore` file to keep your secrets safe.
</Warning>

## 4. Project Structure

Your project structure should look like this:

```
my-bags-project/
├── package.json
├── tsconfig.json
├── .env
├── .gitignore
└── src/
    └── (your TypeScript files will go here)
```

Make sure to add `.env` to your `.gitignore` file:

```bash theme={null}
# .gitignore
.env
node_modules/
dist/
```

You are now ready to follow our how-to guides! Each guide will include the complete setup code needed to initialize the SDK and run the examples.
