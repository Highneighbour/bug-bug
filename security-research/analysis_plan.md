# Yearn Finance Deep Security Research Plan

## Attack Vectors to Investigate

### 1. Reentrancy Vulnerabilities
- Cross-contract reentrancy in deposit/withdraw flows
- Reentrancy through strategy callbacks
- Read-only reentrancy for price manipulation

### 2. Accounting & State Manipulation
- Total assets calculation manipulation
- Share price manipulation during deposits/withdrawals  
- Profit locking mechanism bypass
- First depositor attack vectors
- Rounding errors in share calculations

### 3. Access Control & Privilege Escalation
- Role management vulnerabilities
- Emergency shutdown bypass
- Strategy revoke/force revoke edge cases
- Debt management authorization issues

### 4. Oracle & Price Manipulation
- convertToAssets/convertToShares manipulation
- Strategy reporting manipulation
- Unrealized loss calculation exploits

### 5. Flash Loan & MEV Attacks
- Sandwich attacks on deposits/withdrawals
- Flash loan price manipulation
- Front-running debt updates

### 6. Strategy Integration Risks
- Malicious strategy registration
- Strategy debt manipulation
- Unrealized loss bypass
- Buy debt mechanism exploits

### 7. Edge Cases & Integer Issues
- Division by zero scenarios
- Overflow/underflow in Vyper
- MAX_UINT256 handling
- Zero share/asset edge cases

### 8. Profit Unlocking Mechanism
- Profit unlocking rate manipulation
- PPS spike through unlock mechanism
- Time-based attack vectors

