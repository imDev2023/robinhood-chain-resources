// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StonkEthFaucet is Ownable, ReentrancyGuard {
    uint256 public constant CLAIM_COOLDOWN = 1 days;

    mapping(address => uint256) public lastClaimAt;
    uint256 public claimAmountWei;

    event FaucetClaimed(address indexed user, uint256 amount, uint256 nextClaimAt);
    event ClaimAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event FaucetFunded(address indexed from, uint256 amount);
    event FaucetWithdrawn(address indexed to, uint256 amount);

    constructor(uint256 initialClaimAmountWei, address initialOwner) Ownable(initialOwner) {
        require(initialClaimAmountWei > 0, "claim amount=0");
        claimAmountWei = initialClaimAmountWei;
    }

    receive() external payable {
        emit FaucetFunded(msg.sender, msg.value);
    }

    function addFunds() external payable {
        require(msg.value > 0, "fund=0");
        emit FaucetFunded(msg.sender, msg.value);
    }

    function canClaim(address user) public view returns (bool) {
        return block.timestamp >= nextClaimTime(user);
    }

    function nextClaimTime(address user) public view returns (uint256) {
        uint256 last = lastClaimAt[user];
        if (last == 0) return 0;
        return last + CLAIM_COOLDOWN;
    }

    function claim() external nonReentrant {
        require(canClaim(msg.sender), "claim cooldown");
        require(address(this).balance >= claimAmountWei, "faucet empty");

        lastClaimAt[msg.sender] = block.timestamp;
        (bool ok, ) = payable(msg.sender).call{value: claimAmountWei}("");
        require(ok, "eth transfer failed");

        emit FaucetClaimed(msg.sender, claimAmountWei, block.timestamp + CLAIM_COOLDOWN);
    }

    function setClaimAmountWei(uint256 newAmountWei) external onlyOwner {
        require(newAmountWei > 0, "claim amount=0");
        uint256 old = claimAmountWei;
        claimAmountWei = newAmountWei;
        emit ClaimAmountUpdated(old, newAmountWei);
    }

    function withdraw(address payable to, uint256 amountWei) external onlyOwner {
        require(to != address(0), "to=0");
        require(amountWei <= address(this).balance, "insufficient balance");
        (bool ok, ) = to.call{value: amountWei}("");
        require(ok, "withdraw failed");
        emit FaucetWithdrawn(to, amountWei);
    }
}
