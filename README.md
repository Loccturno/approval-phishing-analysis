# Approval Phishing Analysis

Real-world analysis of a malicious "claim token" smart contract pattern, 
based on a scam token received in my own wallet.

## Contents
- `approval-phishing-scam.sol` — Reconstructed scam contract
- `analysis.md` — Full breakdown of the attack mechanism

## Key Takeaway
Scam tokens with "claim" functions exploit the ERC20 `approve` + `transferFrom` 
pattern to drain victims' valuable tokens (USDT, USDC, etc.) under the guise 
of distributing rewards.
