// Headless wallet, tier 0: read-only EIP-1193 + EIP-6963 provider.
//
// Rendered from this template by scripts/make-observer.mjs, then registered with:
//   agent-browser open <url> --init-script <rendered file>
// or with Playwright:
//   await page.addInitScript({ path: '<rendered file>' })
//
// It reports an address, forwards every read to the chain's own RPC, announces
// itself over EIP-6963, and NEVER holds a private key.
// Writes (eth_sendTransaction, eth_signTransaction, wallet_sendCalls) are
// recorded into window.__HW.capture and rejected with 4001, so the dapp shows a
// clean user-rejected state instead of hanging.
// Signature challenges are parked on window.__HW.pending for an out-of-page
// signer, so no key ever enters the page's JavaScript context.
(() => {
  const CONFIG = {
  "chainId": 4663,
  "chainName": "Robinhood Chain",
  "address": "0xTEST_WALLET_ADDRESS_REDACTED",
  "rpcUrls": [
    "https://rpc.mainnet.chain.robinhood.com",
    "https://robinhood-rpc.publicnode.com"
  ],
  "walletName": "Headless Wallet",
  "rdns": "dev.headless.wallet",
  "uuid": "a0b2b7ca-4e96-4fe8-ac05-7866af8d4f95",
  "icon": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiI+PHJlY3Qgd2lkdGg9Ijk2IiBoZWlnaHQ9Ijk2IiBmaWxsPSIjMzM4OWU2Ii8+PC9zdmc+",
  "signMode": "park",
  "sendMode": "reject",
  "isMetaMask": true,
  "explorer": null
};

  const ADDRESS = CONFIG.address;
  const CHAIN_ID_HEX = '0x' + CONFIG.chainId.toString(16);
  const CHAIN_ID_DEC = String(CONFIG.chainId);
  const RPCS = CONFIG.rpcUrls.slice();
  const SIGN_MODE = CONFIG.signMode || 'park'; // 'park' | 'reject'
  const SEND_MODE = CONFIG.sendMode || 'reject'; // 'reject' only in tier 0

  const capture = [];
  let rpcId = 1000;
  let rpcCursor = 0;

  const record = (method, params) => {
    const entry = { t: new Date().toISOString(), chainId: CONFIG.chainId, method, params };
    capture.push(entry);
    try {
      const prev = JSON.parse(localStorage.getItem('__HW_CAPTURE') || '[]');
      prev.push(entry);
      localStorage.setItem('__HW_CAPTURE', JSON.stringify(prev));
    } catch (e) {}
    console.log('[HW CAPTURE]', method, JSON.stringify(params));
    return entry;
  };

  // Round-robin across every configured RPC so one dead or rate-limited
  // endpoint does not take the session down.
  const rpc = async (method, params) => {
    let lastErr;
    for (let i = 0; i < RPCS.length; i++) {
      const url = RPCS[(rpcCursor + i) % RPCS.length];
      try {
        const r = await fetch(url, {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({ jsonrpc: '2.0', id: rpcId++, method, params: params || [] }),
        });
        if (!r.ok) throw new Error('HTTP ' + r.status + ' from ' + url);
        const j = await r.json();
        if (j.error) {
          // A real JSON-RPC error is an answer, not a transport failure.
          // Do not fail over: every endpoint will say the same thing.
          throw Object.assign(new Error(j.error.message), { code: j.error.code, __rpcError: true });
        }
        rpcCursor = (rpcCursor + i) % RPCS.length;
        return j.result;
      } catch (e) {
        if (e && e.__rpcError) throw e;
        lastErr = e;
        console.warn('[HW RPC] endpoint failed, trying next:', url, e && e.message);
      }
    }
    throw lastErr || new Error('no RPC endpoint configured');
  };

  const rejected = (m) =>
    Object.assign(new Error('User rejected the request. [headless-wallet observer: ' + m + ' recorded, not performed]'), {
      code: 4001,
    });

  const listeners = {};
  const emit = (ev, a) => (listeners[ev] || []).forEach((f) => { try { f(a); } catch (e) {} });

  // --- out-of-page signing bridge -----------------------------------------
  // The provider parks a challenge and blocks. A signer outside the browser
  // signs it and calls window.__HW.provide(id, signature).
  let pendingSeq = 0;
  const pendingMap = {};
  const park = (method, params) =>
    new Promise((resolve, reject) => {
      const id = ++pendingSeq;
      pendingMap[id] = { resolve, reject };
      const req = { id, method, params, t: new Date().toISOString() };
      HW.pending = req;
      window.__PENDING_SIGN = req; // legacy alias
      console.log('[HW PARKED SIGN]', id, method);
    });

  const provide = (id, sig) => {
    const p = pendingMap[id];
    if (!p) return 'no such pending id ' + id;
    delete pendingMap[id];
    if (HW.pending && HW.pending.id === id) { HW.pending = null; window.__PENDING_SIGN = null; }
    p.resolve(sig);
    return 'resolved ' + id;
  };

  const rejectPending = (id) => {
    const p = pendingMap[id];
    if (!p) return 'no such pending id ' + id;
    delete pendingMap[id];
    if (HW.pending && HW.pending.id === id) { HW.pending = null; window.__PENDING_SIGN = null; }
    p.reject(rejected('signature'));
    return 'rejected ' + id;
  };

  const SIGN_METHODS = [
    'personal_sign',
    'eth_sign',
    'eth_signTypedData',
    'eth_signTypedData_v1',
    'eth_signTypedData_v3',
    'eth_signTypedData_v4',
  ];
  const SEND_METHODS = ['eth_sendTransaction', 'eth_signTransaction', 'wallet_sendCalls'];

  const provider = {
    isMetaMask: CONFIG.isMetaMask !== false,
    isConnected: () => true,
    chainId: CHAIN_ID_HEX,
    networkVersion: CHAIN_ID_DEC,
    selectedAddress: ADDRESS,
    _metamask: { isUnlocked: async () => true },

    async request({ method, params }) {
      if (SIGN_METHODS.indexOf(method) !== -1) {
        record(method, params);
        if (SIGN_MODE === 'reject') throw rejected(method);
        return await park(method, params);
      }

      if (SEND_METHODS.indexOf(method) !== -1) {
        record(method, params);
        throw rejected(method);
      }

      switch (method) {
        case 'eth_requestAccounts':
        case 'eth_accounts':
          return [ADDRESS];
        case 'eth_chainId':
          return CHAIN_ID_HEX;
        case 'net_version':
          return CHAIN_ID_DEC;
        case 'eth_coinbase':
          return ADDRESS;
        case 'wallet_switchEthereumChain':
        case 'wallet_addEthereumChain':
        case 'wallet_registerOnboarding':
        case 'wallet_watchAsset':
          record(method, params);
          return null;
        case 'wallet_requestPermissions':
          return [
            {
              parentCapability: 'eth_accounts',
              caveats: [{ type: 'restrictReturnedAccounts', value: [ADDRESS] }],
            },
          ];
        case 'wallet_getPermissions':
          return [{ parentCapability: 'eth_accounts' }];
        case 'wallet_getCapabilities':
          return {};

        // Keep the flow alive so the dapp reaches its send step and we get to
        // see the calldata it would have broadcast.
        case 'eth_estimateGas':
          record('eth_estimateGas', params);
          try {
            return await rpc(method, params);
          } catch (e) {
            return '0x7a1200';
          }

        default:
          return await rpc(method, params);
      }
    },

    on(ev, cb) { (listeners[ev] = listeners[ev] || []).push(cb); return this; },
    removeListener(ev, cb) { listeners[ev] = (listeners[ev] || []).filter((f) => f !== cb); return this; },
    // legacy shims some older dapps still call
    enable() { return this.request({ method: 'eth_requestAccounts' }); },
    send(a, b) {
      if (typeof a === 'string') return this.request({ method: a, params: b });
      return this.request(a);
    },
    sendAsync(payload, cb) {
      this.request(payload).then(
        (result) => cb(null, { id: payload.id, jsonrpc: '2.0', result }),
        (err) => cb(err)
      );
    },
  };

  const HW = {
    config: CONFIG,
    address: ADDRESS,
    provider,
    capture,
    pending: null,
    provide,
    reject: rejectPending,
    dump: () => JSON.stringify(capture, null, 1),
    clear: () => { capture.length = 0; try { localStorage.removeItem('__HW_CAPTURE'); } catch (e) {} },
    rpc,
  };
  window.__HW = HW;

  // Legacy aliases, kept so older archive notes and scripts keep working.
  window.__CAPTURE = capture;
  window.__CAPTURE_DUMP = HW.dump;
  window.__CAPTURE_CLEAR = HW.clear;
  window.__PROVIDE_SIG = provide;
  window.__REJECT_SIG = rejectPending;

  try {
    Object.defineProperty(window, 'ethereum', { value: provider, configurable: true, writable: true });
  } catch (e) {
    window.ethereum = provider;
  }

  // EIP-6963 discovery. This is how wagmi, RainbowKit, ConnectKit, Privy and
  // Dynamic actually enumerate wallets. A provider that only sets
  // window.ethereum will not appear in a modern picker at all.
  const info = {
    uuid: CONFIG.uuid,
    name: CONFIG.walletName,
    rdns: CONFIG.rdns,
    icon: CONFIG.icon,
  };
  const announce = () =>
    window.dispatchEvent(
      new CustomEvent('eip6963:announceProvider', { detail: Object.freeze({ info, provider }) })
    );
  window.addEventListener('eip6963:requestProvider', announce);
  announce();
  // Late announcements: React connect modals mount well after page load and
  // only listen from the moment they mount.
  setTimeout(announce, 300);
  setTimeout(announce, 1500);
  setTimeout(announce, 4000);

  setTimeout(() => emit('connect', { chainId: CHAIN_ID_HEX }), 0);
  console.log('[headless-wallet] observer installed for', ADDRESS, 'on chain', CONFIG.chainId);
})();
