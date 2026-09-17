// Read-only EIP-1193 provider for archiving wallet-gated UI.
// Registered with: agent-browser open --init-script <this file>
//
// It reports an address and forwards reads to the app's own RPC proxy.
// It NEVER holds a private key and NEVER signs or broadcasts anything.
// Every eth_sendTransaction / personal_sign / eth_signTypedData_v4 is recorded
// into window.__CAPTURE and then rejected with 4001 (user rejected), so the
// dapp shows a clean rejection instead of hanging.
(() => {
  const ADDRESS = '0xTEST_WALLET_ADDRESS_REDACTED';
  const CHAIN_ID = '0x1237';           // 4663
  const RPC = 'https://app.doppler.lol/api/rpc/4663';

  const CAPTURE = [];
  let rpcId = 1000;

  const record = (method, params) => {
    const entry = { t: new Date().toISOString(), method, params };
    CAPTURE.push(entry);
    try {
      const prev = JSON.parse(localStorage.getItem('__CAPTURE') || '[]');
      prev.push(entry);
      localStorage.setItem('__CAPTURE', JSON.stringify(prev));
    } catch (e) {}
    console.log('[CAPTURE]', method, JSON.stringify(params));
  };

  const rpc = async (method, params) => {
    const r = await fetch(RPC, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ jsonrpc: '2.0', id: rpcId++, method, params: params || [] }),
    });
    const j = await r.json();
    if (j.error) throw Object.assign(new Error(j.error.message), { code: j.error.code });
    return j.result;
  };

  const rejected = (m) => Object.assign(new Error('User rejected the request. [archive harness: ' + m + ' recorded, not performed]'), { code: 4001 });

  const listeners = {};
  const emit = (ev, a) => (listeners[ev] || []).forEach((f) => { try { f(a); } catch (e) {} });

  // --- out-of-page signing bridge -------------------------------------------
  // The provider parks a signing challenge on window.__PENDING_SIGN and blocks.
  // An operator outside the browser signs it and calls window.__PROVIDE_SIG.
  // No private key ever enters this page.
  let pendingSeq = 0;
  const pending = {};
  const park = (method, params) => new Promise((resolve, reject) => {
    const id = ++pendingSeq;
    pending[id] = { resolve, reject };
    window.__PENDING_SIGN = { id, method, params };
    console.log('[PARKED SIGN]', id, method);
  });
  window.__PROVIDE_SIG = (id, sig) => {
    const p = pending[id];
    if (!p) return 'no such pending id ' + id;
    delete pending[id];
    if (window.__PENDING_SIGN && window.__PENDING_SIGN.id === id) window.__PENDING_SIGN = null;
    p.resolve(sig);
    return 'resolved ' + id;
  };
  window.__REJECT_SIG = (id) => {
    const p = pending[id];
    if (!p) return 'no such pending id ' + id;
    delete pending[id];
    if (window.__PENDING_SIGN && window.__PENDING_SIGN.id === id) window.__PENDING_SIGN = null;
    p.reject(rejected('signature'));
    return 'rejected ' + id;
  };

  const provider = {
    isMetaMask: true,
    isConnected: () => true,
    chainId: CHAIN_ID,
    networkVersion: '4663',
    selectedAddress: ADDRESS,
    _metamask: { isUnlocked: async () => true },

    async request({ method, params }) {
      switch (method) {
        case 'eth_requestAccounts':
        case 'eth_accounts':
											return [ADDRESS];
        case 'eth_chainId':               return CHAIN_ID;
        case 'net_version':               return '4663';
        case 'eth_coinbase':              return ADDRESS;
        case 'wallet_switchEthereumChain':
        case 'wallet_addEthereumChain':
        case 'wallet_registerOnboarding':
          return null;
        case 'wallet_requestPermissions':
          return [{ parentCapability: 'eth_accounts', caveats: [{ type: 'restrictReturnedAccounts', value: [ADDRESS] }] }];
        case 'wallet_getPermissions':
          return [{ parentCapability: 'eth_accounts' }];

        // Signing: parked for the out-of-page signer.
        case 'personal_sign':
        case 'eth_sign':
        case 'eth_signTypedData':
        case 'eth_signTypedData_v3':
        case 'eth_signTypedData_v4':
          record(method, params);
          return await park(method, params);

        // Spending: recorded, never performed.
        case 'eth_sendTransaction':
        case 'eth_signTransaction':
        case 'wallet_sendCalls':
          record(method, params);
          throw rejected(method);

        // Keep the flow alive so the app reaches the send step.
        case 'eth_estimateGas':
          record('eth_estimateGas', params);
          try { return await rpc(method, params); } catch (e) { return '0x7a1200'; }

        default:
          return await rpc(method, params);
      }
    },
    on(ev, cb) { (listeners[ev] = listeners[ev] || []).push(cb); return this; },
    removeListener(ev, cb) { listeners[ev] = (listeners[ev] || []).filter((f) => f !== cb); return this; },
    // legacy shims
    enable() { return this.request({ method: 'eth_requestAccounts' }); },
    send(a, b) {
      if (typeof a === 'string') return this.request({ method: a, params: b });
      return this.request(a);
    },
    sendAsync(payload, cb) {
      this.request(payload).then((result) => cb(null, { id: payload.id, jsonrpc: '2.0', result }),
                                 (err) => cb(err));
    },
  };

  try {
    Object.defineProperty(window, 'ethereum', { value: provider, configurable: true, writable: true });
  } catch (e) { window.ethereum = provider; }

  // EIP-6963 discovery, which is how wagmi / Privy actually find wallets.
  const info = {
    uuid: '11111111-2222-3333-4444-555555555555',
    name: 'Archive Harness',
    rdns: 'lol.doppler.archive.harness',
    icon: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI5NiIgaGVpZ2h0PSI5NiI+PHJlY3Qgd2lkdGg9Ijk2IiBoZWlnaHQ9Ijk2IiBmaWxsPSIjMzM4OWU2Ii8+PC9zdmc+',
  };
  const announce = () => window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
    detail: Object.freeze({ info, provider }),
  }));
  window.addEventListener('eip6963:requestProvider', announce);
  announce();
  setTimeout(announce, 300);
  setTimeout(announce, 1500);

  window.__CAPTURE = CAPTURE;
  window.__CAPTURE_DUMP = () => JSON.stringify(CAPTURE, null, 1);
  window.__CAPTURE_CLEAR = () => { CAPTURE.length = 0; localStorage.removeItem('__CAPTURE'); };
  setTimeout(() => emit('connect', { chainId: CHAIN_ID }), 0);
  console.log('[archive harness] read-only provider installed for', ADDRESS);
})();
