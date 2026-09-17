import sys, json
sys.path.insert(0, ".")
from rpc import call

FACT_W = "0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1"
FACT_S = "0xd0A93885a387e3a8a14dd82776CF9104a3676b3A"
FACT_L = "0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb"
HOOK_W = "0x35c0098836FA0d10A015A95bf02C16387814f0cC"
HOOK_WR = "0x730AbADbB4f328520e5350F59126fbE1D67F70cc"
HOOK_S = "0x5DaA88b65Bd47199eC92d3cDe01B56348e1270CC"
HOOK_SENTRY = "0xA695f84C86367d5aEA445e8289DBC7C4C4E530cc"
SPLIT = "0x75450496fe333A93e1327368aa3c4130BF008697"
VAULT = "0x0F0E601041Ec765B8bAB8c166840E291253F2Df0"
LOCKER = "0xbd0E7a242A323E5e4799Abe09b7516D9dA5ea81D"

def rd(label, to, sig, tout, tin=(), args=()):
    try:
        r = call(to, sig, list(tin), list(args), list(tout))
    except Exception as e:
        r = {"error": str(e)}
    if isinstance(r, tuple) and len(r) == 1:
        r = r[0]
    print(f"{label:52s} {sig:34s} = {r}")

for nm, f in (("factory WETH", FACT_W), ("factory stock", FACT_S)):
    for sig, t in (("owner()", ("address",)), ("treasury()", ("address",)), ("vault()", ("address",)),
                   ("hook()", ("address",)), ("reflectionHook()", ("address",)), ("poolManager()", ("address",)),
                   ("creatorFeeBps()", ("uint256",)), ("totalTokensDeployed()", ("uint256",)),
                   ("TICK_SPACING()", ("int24",))):
        rd(nm, f, sig, t)
    rd(nm, f, "getSupportedBaseTokens()", ("address[]",))

for sig, t in (("owner()", ("address",)), ("treasury()", ("address",)), ("creatorFeeBps()", ("uint256",)),
               ("CREATOR_FEE_BPS()", ("uint256",)), ("FEE_TIER()", ("uint24",)),
               ("totalTokensDeployed()", ("uint256",)), ("npm()", ("address",))):
    rd("factory legacy V3", FACT_L, sig, t)

for nm, h in (("hook WETH launch", HOOK_W), ("hook WETH reflections", HOOK_WR), ("hook stock", HOOK_S)):
    for sig, t in (("startFee()", ("uint24",)), ("endFee()", ("uint24",)), ("halfLife()", ("uint256",)),
                   ("holdDuration()", ("uint256",)), ("reflectionStartDelay()", ("uint256",)),
                   ("earlyCreatorBps()", ("uint256",)), ("earlyTreasuryBps()", ("uint256",)),
                   ("lateCreatorBps()", ("uint256",)), ("lateLpBps()", ("uint256",)),
                   ("lateReflectionBps()", ("uint256",)), ("factory()", ("address",)),
                   ("poolManager()", ("address",))):
        rd(nm, h, sig, t)

for sig, t in (("startFee()", ("uint24",)), ("endFee()", ("uint24",)), ("halfLife()", ("uint256",)),
               ("holdDuration()", ("uint256",)), ("earlyExitFee()", ("uint24",)),
               ("lpShareBps()", ("uint256",)), ("reflectionShareBps()", ("uint256",)),
               ("treasuryShareBps()", ("uint256",)), ("treasury()", ("address",)),
               ("sentry()", ("address",)), ("weth()", ("address",)), ("launcher()", ("address",)),
               ("launchedAt()", ("uint256",)), ("currentFee()", ("uint24",))):
    rd("hook SENTRY", HOOK_SENTRY, sig, t)

for sig, t in (("forwardBps()", ("uint256",)), ("treasuryWallet()", ("address",)), ("sentry()", ("address",)),
               ("weth()", ("address",)), ("usdg()", ("address",)), ("owner()", ("address",)),
               ("keeper()", ("address",)), ("sentryConfigured()", ("bool",)), ("v3Router()", ("address",))):
    rd("treasury splitter", SPLIT, sig, t)

for sig, t in (("admin()", ("address",)), ("creatorFeeBps()", ("uint256",)), ("treasury()", ("address",)),
               ("v4FactoryWeth()", ("address",)), ("v4FactoryStock()", ("address",)),
               ("v3Factory()", ("address",)), ("v3Npm()", ("address",)), ("v3Held()", ("uint256",)),
               ("poolManager()", ("address",))):
    rd("LP vault", VAULT, sig, t)

for sig, t in (("lockCount()", ("uint256",)),):
    rd("token locker", LOCKER, sig, t)
