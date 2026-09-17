# AgentTokenV4-Clone-Example-BLITZO - 0x21C6b18b64Ab4c8051138fc05B70ac74deCC84e9

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x21C6b18b64Ab4c8051138fc05B70ac74deCC84e9
Verified: False (no source on Blockscout; bytecode.hex holds eth_getCode output).
Creator: None.
Creation tx: None.

EIP-1167 minimal proxy pointing at AgentTokenV4-Impl 0x581f7B996E6D3E436c537989157c9CB36421419b. Every agent token launched through BondingV5 is such a clone (45 bytes of runtime code). Blockscout shows these as unverified because the clone itself has no source; the ABI is the implementation's. Reads for this token are in _raw/rpc/agenttoken-vetoken-reads.txt.
