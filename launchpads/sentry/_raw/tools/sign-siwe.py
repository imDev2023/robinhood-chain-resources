# Signs a parked personal_sign challenge with the project's shared test wallet.
# The key is read inside this process and never printed; only the signature is emitted.
import os, sys
from eth_account import Account
from eth_account.messages import encode_defunct

ENVFILE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/.env.testwallet"
key = None
for line in open(ENVFILE):
    line = line.strip()
    if line.startswith("TEST_WALLET_PRIVATE_KEY"):
        key = line.split("=", 1)[1].strip().strip('"').strip("'")
if not key:
    sys.exit("no TEST_WALLET_PRIVATE_KEY in .env.testwallet")
msg_hex = sys.argv[1]
if msg_hex.startswith("0x"):
    msg = bytes.fromhex(msg_hex[2:])
else:
    msg = msg_hex.encode()
acct = Account.from_key(key)
sig = Account.sign_message(encode_defunct(msg), private_key=key)
print(acct.address)
print(sig.signature.hex() if sig.signature.hex().startswith("0x") else "0x" + sig.signature.hex())
