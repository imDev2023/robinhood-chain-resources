> ## Documentation Index
> Fetch the complete documentation index at: https://docs.goldsky.com/llms.txt
> Use this file to discover all available pages before exploring further.

# Robinhood Chain

export const ChainComposeSection = ({chainName, primarySlug, mainnetSupported = true, testnetSupported = true, gasSponsoringSupported = false, gasSponsoringTestnetSupported = false, partnerSponsored = false}) => {
  const badgeStyle = {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: '600',
    marginRight: '6px'
  };
  const isSupported = mainnetSupported || testnetSupported;
  if (!isSupported) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(156, 163, 175, 0.2)',
      color: 'rgba(156, 163, 175, 0.8)'
    }}>NOT YET AVAILABLE</span>
        </p>
        <p>Compose lets you build offchain-to-onchain systems that durably move data and execute logic between your application and the blockchain. Learn more about what you can build with Compose in the <a href="/compose/introduction">Compose documentation</a>. Compose is not currently enabled for {chainName}, but we'd love to change that. </p>
        <p>
          <strong>From the {chainName} team?</strong> <a href="https://cal.com/team/goldsky/website-intro">Book a call</a> to explore enabling Compose for your ecosystem.<br />
          <strong>Building on {chainName}?</strong> <a href="https://cal.com/team/goldsky/website-intro">Contact us</a> about dedicated infrastructure options.
        </p>
      </>;
  }
  const gasBadgeLabel = (() => {
    if (mainnetSupported && testnetSupported) {
      if (gasSponsoringSupported && gasSponsoringTestnetSupported) return 'GAS SPONSORING SUPPORTED';
      if (gasSponsoringSupported) return 'GAS SPONSORING SUPPORTED (MAINNET)';
      if (gasSponsoringTestnetSupported) return 'GAS SPONSORING SUPPORTED (TESTNET)';
      return null;
    }
    if (mainnetSupported && gasSponsoringSupported) return 'GAS SPONSORING SUPPORTED';
    if (testnetSupported && gasSponsoringTestnetSupported) return 'GAS SPONSORING SUPPORTED';
    return null;
  })();
  const gasNotSupported = !gasBadgeLabel;
  return <>
      <p>
        {mainnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
    color: 'rgba(34, 197, 94, 0.6)'
  }}>MAINNET SUPPORTED</span>}
        {testnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    color: 'rgba(59, 130, 246, 0.6)'
  }}>TESTNET SUPPORTED</span>}
        {gasBadgeLabel && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(234, 179, 8, 0.15)',
    color: 'rgba(202, 138, 4, 0.9)'
  }}>{gasBadgeLabel}</span>}
        {gasNotSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(156, 163, 175, 0.2)',
    color: 'rgba(156, 163, 175, 0.8)'
  }}>GAS SPONSORING NOT AVAILABLE</span>}
        {partnerSponsored && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(168, 85, 247, 0.25)',
    color: 'rgb(168, 85, 247)'
  }}>PARTNER SPONSORED</span>}
      </p>
      <p>Compose lets you build offchain-to-onchain systems that durably move data and execute logic between your application and {chainName}. Write TypeScript code that runs in verifiable sandboxes with full tracing and auditability.</p>

      <p>
        {gasNotSupported ? <>Gas sponsoring is not available on {chainName} — Compose tasks that submit transactions must use a funded EOA. See <a href="/chains/supported-networks#compose">the Compose networks table</a> for the full list.</> : <>Smart-wallet tasks on {chainName} can sponsor user gas through one of Compose's bundler providers (Alchemy, Pimlico, or Gelato). See <a href="/chains/supported-networks#compose">the Compose networks table</a> for the full list.</>}
      </p>

      <h3>Quick start</h3>
      <p>Initialize a new Compose application:</p>
      <CodeBlock language="bash" filename="Initialize app">
{`goldsky compose init my-${primarySlug}-app`}
      </CodeBlock>
      
      <p>This creates a project structure with example tasks you can customize:</p>
      <CodeBlock language="text" filename="Project structure">
{`my-${primarySlug}-app/
├── compose.yaml      # App manifest and configuration
├── tasks/            # Executable task definitions
│   ├── task_a.ts
│   └── task_b.ts
└── .gitignore`}
      </CodeBlock>
      
      <h3>Run locally</h3>
      <p>Start your Compose application in development mode:</p>
      <CodeBlock language="bash" filename="Start app">
{`cd my-${primarySlug}-app
goldsky compose start`}
      </CodeBlock>
      
      <p>Test a task execution:</p>
      <CodeBlock language="bash" filename="Call task">
{`goldsky compose callTask my_task '{}' --env local`}
      </CodeBlock>
      
      <h3>Deploy to production</h3>
      <p>When ready, deploy your application to Goldsky's managed infrastructure:</p>
      <CodeBlock language="bash" filename="Deploy">
{`goldsky compose deploy`}
      </CodeBlock>
      
      <p>For the full guide on building Compose applications, see the <a href="/compose/introduction">Compose documentation</a>.</p>
    </>;
};

export const ChainEdgeSection = ({chainName, primaryChainId, primaryEdgeAlias, secondaryChainId, secondaryEdgeAlias, mainnetSupported = true, testnetSupported = true, partnerSponsored = false, isEVMCompatible = true}) => {
  const badgeStyle = {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: '600',
    marginRight: '6px'
  };
  const isSupported = mainnetSupported || testnetSupported;
  if (!isEVMCompatible) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(239, 68, 68, 0.15)',
      color: 'rgba(239, 68, 68, 0.8)'
    }}>NOT COMPATIBLE</span>
        </p>
        <p>Edge RPC is designed for EVM-compatible chains and is not available for {chainName}.</p>
        <p>{chainName} uses a different virtual machine architecture. For {chainName} data access, consider using <a href="/mirror/introduction">Mirror</a> or <a href="/turbo-pipelines/introduction">Turbo</a> pipelines which support non-EVM chains.</p>
      </>;
  }
  if (!isSupported) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(156, 163, 175, 0.2)',
      color: 'rgba(156, 163, 175, 0.8)'
    }}>NOT YET AVAILABLE</span>
        </p>
        <p>Edge RPC provides reliable, high-performance RPC access with low latency via multi-region CDN, intelligent caching, automatic failover, and built-in observability—optimized for both indexing backends and frontend applications. Learn more in the <a href="/edge-rpc/introduction">Edge RPC documentation</a>.</p>
        <p>Edge RPC is not currently enabled for {chainName}, but we'd love to change that.</p>
        <p>
          <strong>From the {chainName} team?</strong> <a href="https://cal.com/team/goldsky/website-intro">Book a call</a> to explore enabling Edge RPC for your ecosystem.<br />
          <strong>Building on {chainName}?</strong> <a href="https://cal.com/team/goldsky/website-intro">Contact us</a> about dedicated infrastructure options.
        </p>
      </>;
  }
  return <>
      <p>
        {mainnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
    color: 'rgba(34, 197, 94, 0.6)'
  }}>MAINNET SUPPORTED</span>}
        {testnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    color: 'rgba(59, 130, 246, 0.6)'
  }}>TESTNET SUPPORTED</span>}
        {partnerSponsored && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(168, 85, 247, 0.25)',
    color: 'rgb(168, 85, 247)'
  }}>PARTNER SPONSORED</span>}
      </p>
      <p>Edge RPC provides reliable, high-performance RPC access for {chainName} with low latency via multi-region CDN, intelligent caching, automatic failover, and built-in observability—optimized for both indexing backends and frontend applications.</p>
      
      <h3>RPC endpoints</h3>
      <table>
        <thead>
          <tr>
            <th>Network</th>
            <th>Chain ID</th>
            <th>Endpoint</th>
          </tr>
        </thead>
        <tbody>
          {mainnetSupported && primaryChainId && <tr>
              <td>Mainnet</td>
              <td><code>{primaryChainId}</code></td>
              <td><code>https://edge.goldsky.com/standard/evm/{primaryChainId}?secret=YOUR_SECRET</code></td>
            </tr>}
          {testnetSupported && secondaryChainId && <tr>
              <td>Testnet</td>
              <td><code>{secondaryChainId}</code></td>
              <td><code>https://edge.goldsky.com/standard/evm/{secondaryChainId}?secret=YOUR_SECRET</code></td>
            </tr>}
        </tbody>
      </table>
      
      <h3>Usage examples</h3>
      <CodeGroup>
        <CodeBlock language="bash" filename="curl">
{`curl "https://edge.goldsky.com/standard/evm/${primaryChainId}?secret=YOUR_SECRET" \\
  -X POST \\
  -H "Content-Type: application/json" \\
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'`}
        </CodeBlock>
        <CodeBlock language="javascript" filename="ethers.js">
{`import { JsonRpcProvider } from 'ethers'

const provider = new JsonRpcProvider('https://edge.goldsky.com/standard/evm/${primaryChainId}?secret=YOUR_SECRET')
const blockNumber = await provider.getBlockNumber()`}
        </CodeBlock>
        <CodeBlock language="javascript" filename="viem">
{`import { createPublicClient, http } from 'viem'

const client = createPublicClient({
  transport: http('https://edge.goldsky.com/standard/evm/${primaryChainId}?secret=YOUR_SECRET')
})
const blockNumber = await client.getBlockNumber()`}
        </CodeBlock>
      </CodeGroup>
      
      <p>For the full list of supported RPC methods and configuration options, see the <a href="/edge-rpc/introduction">Edge RPC documentation</a>.</p>
    </>;
};

export const ChainTurboSection = ({chainName, primarySlug, secondarySlug, primaryChainSlug, mainnetSupported = true, testnetSupported = true, partnerSponsored = false}) => {
  const chainSlug = primaryChainSlug || (mainnetSupported ? primarySlug : secondarySlug) || primarySlug;
  const badgeStyle = {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: '600',
    marginRight: '6px'
  };
  const isSupported = mainnetSupported || testnetSupported;
  if (!isSupported) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(156, 163, 175, 0.2)',
      color: 'rgba(156, 163, 175, 0.8)'
    }}>NOT YET AVAILABLE</span>
        </p>
        <p>Turbo provides high-performance streaming data pipelines with sub-second latency for real-time blockchain data. Learn more about what you can build with Turbo in the <a href="/turbo-pipelines/introduction">Turbo documentation</a>. Turbo is not currently enabled for {chainName}, but we'd love to change that.</p>
        <p>
          <strong>From the {chainName} team?</strong> <a href="https://cal.com/team/goldsky/website-intro">Book a call</a> to explore enabling Turbo for your ecosystem.<br />
          <strong>Building on {chainName}?</strong> <a href="https://cal.com/team/goldsky/website-intro">Contact us</a> about dedicated infrastructure options.
        </p>
      </>;
  }
  return <>
      <p>
        {mainnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
    color: 'rgba(34, 197, 94, 0.6)'
  }}>MAINNET SUPPORTED</span>}
        {testnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    color: 'rgba(59, 130, 246, 0.6)'
  }}>TESTNET SUPPORTED</span>}
        {partnerSponsored && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(168, 85, 247, 0.25)',
    color: 'rgb(168, 85, 247)'
  }}>PARTNER SPONSORED</span>}
      </p>
      <p>Turbo pipelines provide high-performance streaming data pipelines with sub-second latency. Deploy a pipeline to start streaming {chainName} data to your preferred destination.</p>
      
      <h3>Quick deploy</h3>
      <p>Validate and deploy a Turbo pipeline with the CLI:</p>
      <CodeBlock language="bash" filename="Deploy pipeline">
{`goldsky turbo validate ${primarySlug}-pipeline.yaml
goldsky turbo apply ${primarySlug}-pipeline.yaml`}
      </CodeBlock>

      <h3>Configuration file</h3>
      <p>Turbo pipelines are defined in a YAML configuration file. Reference a {chainName} dataset by its <code>dataset_name</code> and pinned <code>version</code>, then send it to your configured sink. See the specific {chainName} datasets and versions in the section below.</p>
      <CodeBlock language="yaml" filename={`${primarySlug}-pipeline.yaml`}>
{`name: my-${primarySlug}-pipeline
resource_size: s

sources:
  ${primarySlug}_source:
    type: dataset
    dataset_name: <DATASET_NAME>   # e.g. ${primarySlug}.<dataset>
    version: <DATASET_VERSION>     # pin to a specific version
    start_at: latest               # or 'earliest' to process all historical data

sinks:
  postgres_${primarySlug}:
    type: postgres
    from: ${primarySlug}_source
    schema: public
    table: ${primarySlug}_data
    secret_name: <YOUR_SECRET_NAME>
    primary_key: id`}
      </CodeBlock>

      <h3>Available chain slugs</h3>
      <p>
        {mainnetSupported && <span>Mainnet: <code>{primarySlug}</code></span>}
        {mainnetSupported && testnetSupported && <span> | </span>}
        {testnetSupported && secondarySlug && <span>Testnet: <code>{secondarySlug}</code></span>}
      </p>

      <p>For the full configuration reference, see the <a href="/turbo-pipelines/introduction">Turbo documentation</a>.</p>
    </>;
};

export const ChainMirrorSection = ({chainName, mainnetSupported = true, testnetSupported = true, partnerSponsored = false}) => {
  const badgeStyle = {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: '600',
    marginRight: '6px'
  };
  const isSupported = mainnetSupported || testnetSupported;
  if (!isSupported) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(156, 163, 175, 0.2)',
      color: 'rgba(156, 163, 175, 0.8)'
    }}>NOT YET AVAILABLE</span>
        </p>
        <p>Mirror pipelines let you replicate blockchain data into your own infrastructure in real-time. Learn more about what you can build with Mirror in the <a href="/mirror/introduction">Mirror documentation</a>. Mirror is not currently enabled for {chainName}, but we'd love to change that.</p>
        <p>
          <strong>From the {chainName} team?</strong> <a href="https://cal.com/team/goldsky/website-intro">Book a call</a> to explore enabling Mirror for your ecosystem.<br />
          <strong>Building on {chainName}?</strong> <a href="https://cal.com/team/goldsky/website-intro">Contact us</a> about dedicated infrastructure options.
        </p>
      </>;
  }
  return <>
      <p>
        {mainnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
    color: 'rgba(34, 197, 94, 0.6)'
  }}>MAINNET SUPPORTED</span>}
        {testnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    color: 'rgba(59, 130, 246, 0.6)'
  }}>TESTNET SUPPORTED</span>}
        {partnerSponsored && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(168, 85, 247, 0.25)',
    color: 'rgb(168, 85, 247)'
  }}>PARTNER SPONSORED</span>}
      </p>
      <p>Mirror pipelines allow users to replicate data into their own infrastructure (any of the <a href="/mirror/sinks/supported-sinks">supported sinks</a>) in real time, including both subgraphs as well as chain-level datasets (ie. blocks, logs, transactions, traces). Pipelines can be deployed on Goldsky in 3 ways:</p>
      <ul>
        <li>Using Goldsky Flow on the dashboard, see walkthrough video <a href="/mirror/create-a-pipeline">here</a></li>
        <li>Using the interactive CLI, by entering the command <code>goldsky pipeline create &lt;pipeline-name&gt;</code>. This will kick off a guided flow with the first step to choose the dataset type (project subgraph, community subgraph, or chain-level dataset). You'll then be guided through adding some simple filters to this data and where to persist the results.</li>
        <li>Using a definition file, by entering the command <code>goldsky pipeline create &lt;pipeline-name&gt; --definition-path &lt;path-to-file&gt;</code>. This makes it easier to set up complex pipelines involving multiple sources, multiple sinks, and more complex, SQL-based transformations. For the full reference documentation on, click <a href="/mirror/reference/config-file/pipeline">here</a>.</li>
      </ul>
    </>;
};

export const ChainSubgraphsSection = ({chainName, networks, mainnetSupported = true, testnetSupported = true, partnerSponsored = false, isEVMCompatible = true}) => {
  const renderSlugs = () => {
    if (!networks || networks.length === 0) return null;
    if (networks.length === 1) {
      const [name, slug] = networks[0];
      return <p>
          {name} is available at the chain slug <code>{slug}</code>.
        </p>;
    }
    return <p>
        {networks.map(([name, slug], i) => <span key={slug}>
            {name} (<code>{slug}</code>){i < networks.length - 1 ? ' and ' : ''}
          </span>)}{' '}
        are supported.
      </p>;
  };
  const badgeStyle = {
    display: 'inline-block',
    padding: '2px 8px',
    borderRadius: '4px',
    fontSize: '12px',
    fontWeight: '600',
    marginRight: '6px'
  };
  const isSupported = mainnetSupported || testnetSupported;
  if (!isEVMCompatible) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(239, 68, 68, 0.15)',
      color: 'rgba(239, 68, 68, 0.8)'
    }}>NOT COMPATIBLE</span>
        </p>
        <p>Subgraphs are designed for EVM-compatible chains and are not available for {chainName}.</p>
        <p>{chainName} uses a different virtual machine architecture. For {chainName} data indexing, consider using <a href="/mirror/introduction">Mirror</a> or <a href="/turbo-pipelines/introduction">Turbo</a> pipelines which support non-EVM chains.</p>
      </>;
  }
  if (!isSupported) {
    return <>
        <p>
          <span style={{
      ...badgeStyle,
      backgroundColor: 'rgba(156, 163, 175, 0.2)',
      color: 'rgba(156, 163, 175, 0.8)'
    }}>NOT YET AVAILABLE</span>
        </p>
        <p>Subgraphs let you define custom data schemas and indexing logic to serve blockchain data via GraphQL APIs. Learn more about what you can build with Subgraphs in the <a href="/subgraphs/introduction">Subgraphs documentation</a>. Subgraphs are not currently enabled for {chainName}, but we'd love to change that.</p>
        <p>
          <strong>From the {chainName} team?</strong> <a href="https://cal.com/team/goldsky/website-intro">Book a call</a> to explore enabling Subgraphs for your ecosystem.<br />
          <strong>Building on {chainName}?</strong> <a href="https://cal.com/team/goldsky/website-intro">Contact us</a> about dedicated infrastructure options.
        </p>
      </>;
  }
  return <>
      <p>
        {mainnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(34, 197, 94, 0.1)',
    color: 'rgba(34, 197, 94, 0.6)'
  }}>MAINNET SUPPORTED</span>}
        {testnetSupported && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(59, 130, 246, 0.1)',
    color: 'rgba(59, 130, 246, 0.6)'
  }}>TESTNET SUPPORTED</span>}
        {partnerSponsored && <span style={{
    ...badgeStyle,
    backgroundColor: 'rgba(168, 85, 247, 0.25)',
    color: 'rgb(168, 85, 247)'
  }}>PARTNER SPONSORED</span>}
      </p>
      <p>{chainName} subgraphs can be deployed on Goldsky in 2 ways:</p>
      <ul>
        <li>Via CLI from a local subgraph configuration file. If you are familiar with developing subgraphs already, you'll be familiar with this approach; after defining a subgraph locally (with a <code>subgraph.yaml</code> file, a <code>schema.graphql</code> file, and the necessary mappings to translate raw event data into the entities defined in the schema), you can deploy subgraphs to Goldsky (once the Goldsky CLI is installed) using <code>goldsky subgraph deploy &lt;name&gt;/&lt;version&gt; --path .</code> For more, read the <a href="/subgraphs/deploying-subgraphs">step-by-step guide</a>.</li>
        <li>Via instant subgraphs, where you can pass through a contract address and the ABI for that contract. This is a quick-start option that automatically generates the underlying subgraph configuration files on your behalf, making it easy to extract blockchain event data and serve it as an API endpoint without complex setup. Use the <code>--from-abi</code> flag in the command above instead of <code>--path</code>. For more, read the <a href="/subgraphs/guides/create-a-low-code-subgraph">low-code subgraphs guide</a>.</li>
      </ul>
      {renderSlugs()}
    </>;
};

export const ChainOverview = ({chainName}) => <p>Goldsky is the modern back-end for crypto-enabled products; the infrastructure layer between your application and the blockchain. We handle the complex, undifferentiated work of building on crypto rails: streaming real-time data, maintaining reliable chain connectivity, and executing onchain logic. Teams use Goldsky to ship faster and stay focused on their core product.</p>;

export const ChainHeaderTabs = ({primaryTitle = "Mainnet", primaryIcon = "circle-check", primaryChainId, primaryCurrency, primaryExplorerUrl, secondaryTitle, secondaryIcon = "flask-conical", secondaryChainId, secondaryCurrency, secondaryExplorerUrl, edgeMainnetSupported = false, edgeTestnetSupported = false}) => {
  const renderNetworkTab = (title, icon, chainId, currency, explorerUrl, showEdge) => <Tab title={title} icon={icon}>
      <CardGroup cols={3}>
        <Card title="Chain ID">{chainId}</Card>
        <Card title="Currency">{currency}</Card>
        <Card title="Explorer ↗" href={explorerUrl} />
      </CardGroup>

      {showEdge && chainId && <CodeBlock language="bash" filename="RPC Endpoint" wrap>
          {`https://edge.goldsky.com/standard/evm/${chainId}?secret=YOUR_SECRET`}
        </CodeBlock>}
    </Tab>;
  if (!secondaryTitle) {
    return <Card>
        <Tabs>
          {renderNetworkTab(primaryTitle, primaryIcon, primaryChainId, primaryCurrency, primaryExplorerUrl, edgeMainnetSupported)}
        </Tabs>
      </Card>;
  }
  return <Card>
      <Tabs>
        {renderNetworkTab(primaryTitle, primaryIcon, primaryChainId, primaryCurrency, primaryExplorerUrl, edgeMainnetSupported)}
        {renderNetworkTab(secondaryTitle, secondaryIcon, secondaryChainId, secondaryCurrency, secondaryExplorerUrl, edgeTestnetSupported)}
      </Tabs>
    </Card>;
};

<ChainHeaderTabs primaryTitle="Robinhood Chain Mainnet" primaryChainId="4663" primaryCurrency="ETH" primaryExplorerUrl="https://robinhoodchain.blockscout.com" secondaryTitle="Robinhood Chain Testnet" secondaryChainId="46630" secondaryCurrency="ETH" secondaryExplorerUrl="https://explorer.testnet.chain.robinhood.com" edgeMainnetSupported={true} edgeTestnetSupported={true} />

## Overview

<ChainOverview chainName="Robinhood Chain" />

## Getting started

To use Goldsky, you'll need to create an account, install the CLI, and log in. If you want to use Turbo or Compose, you'll also need to install their respective CLI extensions.

<AccordionGroup>
  <Accordion title="Install Goldsky CLI and log in">
    1. Install the Goldsky CLI:

       **For macOS/Linux:**

       ```shell theme={null}
       curl https://goldsky.com | sh
       ```

       **For Windows:**

       ```shell theme={null}
       npm install -g @goldskycom/cli
       ```

       <Note>Windows users need to have Node.js and npm installed first. Download from [nodejs.org](https://nodejs.org) if not already installed.</Note>
    2. Log into your Project by running:
       ```shell theme={null}
       goldsky login
       ```
       This opens your browser to sign in (Google, GitHub, SSO, or email). Once you authenticate, the CLI is logged in automatically — there's no API key to copy or paste.
       <Note>On a headless or remote machine (or in CI), create an API key on your [Project Settings](https://app.goldsky.com/dashboard/settings) page and pass it directly with `goldsky login --token <API_KEY>`. Use `goldsky login --no-browser` to print the login URL instead of opening a browser.</Note>
    3. Now that you are logged in, run `goldsky` to get started:
       ```shell theme={null}
       goldsky
       ```
  </Accordion>

  <Accordion title="Install Turbo CLI extension">
    If you already have the Goldsky CLI installed, install the Turbo extension by running:

    ```bash theme={null}
    goldsky turbo
    ```

    This will automatically install the Turbo extension. Verify the installation:

    ```bash theme={null}
    goldsky turbo list
    ```

    <Note>
      Make sure to update the CLI to the latest version before running Turbo commands: `curl https://goldsky.com | sh`
    </Note>

    For a complete reference of all Turbo CLI commands, see the [CLI Reference](/turbo-pipelines/cli-reference) guide.
  </Accordion>

  <Accordion title="Install Compose CLI extension">
    If you already have the Goldsky CLI installed, install the Compose extension by running:

    ```bash theme={null}
    goldsky compose install
    ```

    To update to the latest version:

    ```bash theme={null}
    goldsky compose update
    ```

    For more details, see the [Compose quickstart](/compose/quick-start) guide.
  </Accordion>
</AccordionGroup>

## Subgraphs

<ChainSubgraphsSection chainName="Robinhood Chain" networks={[["Robinhood Chain Mainnet", "robinhood-mainnet"], ["Robinhood Chain Testnet", "robinhood-testnet"]]} mainnetSupported={true} testnetSupported={true} partnerSponsored={false} isEVMCompatible={true} />

## Mirror

<ChainMirrorSection chainName="Robinhood Chain" mainnetSupported={true} testnetSupported={true} partnerSponsored={false} />

## Turbo

<ChainTurboSection chainName="Robinhood Chain" primarySlug="robinhood_mainnet" secondarySlug="robinhood_testnet" mainnetSupported={true} testnetSupported={true} partnerSponsored={false} />

## Edge RPC

<ChainEdgeSection chainName="Robinhood Chain" primaryChainId="4663" secondaryChainId="46630" mainnetSupported={true} testnetSupported={true} partnerSponsored={false} isEVMCompatible={true} />

## Compose

<ChainComposeSection chainName="Robinhood Chain" primarySlug="robinhood_mainnet" mainnetSupported={true} testnetSupported={true} gasSponsoringSupported={true} gasSponsoringTestnetSupported={true} partnerSponsored={false} />

## Getting support

Can't find what you're looking for? Reach out to us at [support@goldsky.com](mailto:support@goldsky.com) for help.


## Related topics

- [Tokenized equities & RWA data layer](/solutions/tokenized-equities.md)
- [Supported networks](/chains/supported-networks.md)
- [Payments & fintech on Goldsky](/solutions/payments-fintech.md)
- [Direct indexing as a Mirror pipeline source](/mirror/sources/direct-indexing.md)
- [x402 nanopayments: pay-per-call access to Edge RPC](/edge-rpc/capabilities/x402.md)
