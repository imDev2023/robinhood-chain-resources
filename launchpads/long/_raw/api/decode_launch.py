import json,sys
from eth_abi import decode
def hx(b): return bytes.fromhex(b[2:] if b.startswith("0x") else b)
def dec_create(txjson):
    p=txjson["decoded_input"]["parameters"][0]["value"]
    keys=["initialSupply","numTokensToSell","numeraire","tokenFactory","tokenFactoryData","governanceFactory","governanceFactoryData","poolInitializer","poolInitializerData","liquidityMigrator","liquidityMigratorData","integrator","salt"]
    d=dict(zip(keys,p))
    out={"createParams":{k:(v if not isinstance(v,str) or len(v)<200 else v[:66]+"...") for k,v in d.items()}}
    tf=decode(["string","string","(uint64,uint64)[]","address[]","uint256[]","uint256[]","string","uint256","uint48","address","address[]"],hx(d["tokenFactoryData"]))
    out["tokenFactoryData"]=dict(zip(["name","symbol","vestingSchedules(cliff,duration)","beneficiaries","scheduleIds","amounts","tokenURI","maxBalanceLimit","balanceLimitEnd","controller","excludedFromBalanceLimit"],[list(x) if isinstance(x,tuple) else x for x in tf]))
    pi=decode(["(uint24,int24,int24,(int24,int24,uint16,uint256)[],(address,uint96)[],address,bytes,bytes)"],hx(d["poolInitializerData"]))[0]
    init={"fee":pi[0],"tickSpacing":pi[1],"farTick":pi[2],"curves":[dict(zip(["tickLower","tickUpper","numPositions","shares"],c)) for c in pi[3]],"beneficiaries":[{"beneficiary":b[0],"sharesWad":b[1],"sharesPct":b[1]/1e16} for b in pi[4]],"dopplerHook":pi[5],"onInitCalldata":"0x"+pi[6].hex(),"graduationCalldata":"0x"+pi[7].hex()}
    if len(pi[6])>0:
        r=decode(["(address,address,uint24,uint24,uint32,uint32,uint8,(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256))"],pi[6])[0]
        fd=dict(zip(["assetFeesToAssetBuybackWad","assetFeesToNumeraireBuybackWad","assetFeesToBeneficiaryWad","assetFeesToLpWad","numeraireFeesToAssetBuybackWad","numeraireFeesToNumeraireBuybackWad","numeraireFeesToBeneficiaryWad","numeraireFeesToLpWad"],r[7]))
        init["rehypeInitData"]={"numeraire":r[0],"buybackDst":r[1],"startFee":r[2],"startFeePct":r[2]/1e4,"endFee":r[3],"endFeePct":r[3]/1e4,"durationSeconds":r[4],"startingTime":r[5],"feeRoutingMode":["DirectBuyback","RouteToBeneficiaryFees"][r[6]],"feeDistributionInfo":{k:{"wad":v,"pct":v/1e16} for k,v in fd.items()}}
    out["poolInitializerData"]=init
    return out
if __name__=="__main__":
    tx=json.load(open(sys.argv[1]))
    o=dec_create(tx); o["txHash"]=tx["hash"]; o["from"]=tx["from"]["hash"]; o["timestamp"]=tx["timestamp"]
    json.dump(o,open(sys.argv[2],"w"),indent=1,default=str); print(json.dumps(o,indent=1,default=str))
