# 🎯 COMPREHENSIVE BUG HUNTING STRATEGY FOR YEARN

## ❌ What We've Learned

1. **First Depositor Attack** - Known issue (2021 disclosure)
2. **Locked Profit Overwrite** - Likely by design, not exploitable
3. **Old Vault Code** - Heavily audited (Trail of Bits, ChainSecurity, etc.)

## ✅ WHERE TO FIND REAL BUGS

### Priority 1: NEW CONTRACTS (2023-2024) 🔥

These have FEWER audits and MORE opportunities:

#### **veYFI (Governance Staking)** - Address: `0x90c1f9220d90d3966FbeE24045EDd73E1d588aD5`
- **Why:** Complex voting power calculations
- **Look for:**
  - Vote weight manipulation
  - Early exit exploits
  - Reward distribution bugs
  - Lock time bypass
  - Delegation vulnerabilities

#### **yETH Bootstrap** - Address: `0x2cA7F3Ec538c1f59836BDe0ED93A2D0439f26e5C`
- **Why:** Bootstrap mechanics are often buggy
- **Look for:**
  - Initial liquidity attacks
  - Rate manipulation
  - Exit timing exploits

#### **yETH Merkle Incentives** - Address: `0x05faacC28C27680a9C2727853bEaC27680a5179f`
- **Why:** Merkle trees are complex
- **Look for:**
  - Double-claiming
  - Proof forgery
  - Claim frontrunning
  - Root manipulation

#### **dYFI** - Address: `0x41252E8691e964f7DE35156B68493bAb6797a275`
- **Why:** Token distribution mechanics
- **Look for:**
  - Redemption exploits
  - Ratio manipulation
  - Claim vulnerabilities

### Priority 2: STRATEGY CONTRACTS 🎯

Strategies are LESS audited than core vaults:

**How to find them:**
```python
# Use the helper contracts from Immunefi scope:
# Ethereum: 0x5b4F3BE554a88Bd0f8d8769B9260be865ba03B4a (StrategiesHelper)

# Call: assetsStrategiesAddresses()
# This returns ALL in-scope strategy contracts
```

**What to look for:**
- External protocol integration bugs
- Price oracle manipulation
- Slippage exploits
- Reentrancy
- Flash loan attacks

### Priority 3: CROSS-CONTRACT INTERACTIONS 🔗

These are RARELY audited:

**Examples:**
- Vault ↔ Strategy interaction edge cases
- veYFI ↔ Reward Pool synchronization
- yETH ↔ Bootstrap edge cases
- Governance ↔ Vault upgrade paths

**Look for:**
- State desync
- Race conditions
- Callback vulnerabilities
- Approval exploits

---

## 🛠️ SPECIFIC ATTACK VECTORS TO TEST

### 1. **Economic Exploits**

#### A. Reward Inflation
```python
# Look for contracts with reward distribution
# Check if you can:
- Inflate rewards by depositing/withdrawing rapidly
- Claim rewards multiple times
- Manipulate reward rates
```

#### B. Fee Bypassing
```python
# Check withdrawal/deposit fees
# Can you:
- Bypass fees using flash loans?
- Avoid fees by using alternative entry points?
- Manipulate fee calculations?
```

#### C. Price Manipulation
```python
# For contracts using external prices:
- Flash loan to manipulate AMM price
- Frontrun price updates
- Exploit stale oracle data
```

### 2. **Access Control Exploits**

#### A. Role Escalation
```python
# Check governance functions:
- Can non-privileged users call admin functions?
- Are there delegation bugs?
- Can you become governance via exploit?
```

#### B. Unprotected Initializers
```python
# For proxy contracts:
- Are initialize() functions protected?
- Can you re-initialize?
- Front-run initialization?
```

### 3. **State Manipulation**

#### A. Accounting Bugs
```python
# Look for integer math:
- Rounding errors (especially with different decimals)
- Overflow/underflow (even with SafeMath)
- Division before multiplication
```

#### B. Reentrancy
```python
# Check external calls:
- Transfer hooks (ERC777, ERC721)
- Callback patterns
- Cross-contract calls before state update
```

### 4. **Timing Attacks**

#### A. Front-running
```python
# Exploit transaction ordering:
- MEV sandwich attacks
- Front-run harvests
- Front-run liquidations
```

#### B. Block Timestamp Manipulation
```python
# If contract uses block.timestamp:
- Can miners manipulate (±15 seconds)?
- Race conditions between blocks?
```

---

## 🔬 SPECIFIC CODE PATTERNS TO HUNT

### Pattern 1: Unchecked External Calls

```solidity
// VULNERABLE
token.transfer(user, amount);
// Should check return value!

// SAFE
require(token.transfer(user, amount), "Transfer failed");
```

### Pattern 2: Loops Without Bounds

```solidity
// VULNERABLE
for (uint i = 0; i < userArray.length; i++) {
    // DoS if array too large
}
```

### Pattern 3: Incorrect Equality Checks

```solidity
// VULNERABLE
if (balance == requiredAmount) {
    // Can be bypassed by sending +1 wei
}

// BETTER
if (balance >= requiredAmount) {
```

### Pattern 4: Delegatecall to User Input

```solidity
// CRITICAL
address(target).delegatecall(data);
// Can execute arbitrary code in contract context!
```

### Pattern 5: Approve Race Conditions

```solidity
// VULNERABLE
// User calls approve(spender, 100)
// Then calls approve(spender, 50)
// Attacker can front-run and spend 150 total
```

---

## 📋 SYSTEMATIC TESTING CHECKLIST

### For Each Contract:

#### Phase 1: Reconnaissance
- [ ] Read full contract source code
- [ ] Identify all external calls
- [ ] Map state variables
- [ ] List privileged functions
- [ ] Check for proxies/upgrades

#### Phase 2: Static Analysis
- [ ] Run Slither/Mythril
- [ ] Check for known patterns
- [ ] Review all math operations
- [ ] Verify access controls
- [ ] Check for reentrancy

#### Phase 3: Dynamic Testing
- [ ] Deploy to local fork
- [ ] Test all public functions
- [ ] Try extreme values
- [ ] Test with multiple users
- [ ] Attempt race conditions

#### Phase 4: Integration Testing
- [ ] Test cross-contract calls
- [ ] Try flash loan attacks
- [ ] Attempt price manipulation
- [ ] Test upgrade scenarios
- [ ] Check emergency procedures

---

## 🎯 HIGH-PROBABILITY BUG LOCATIONS

### 1. **New Features** (Added in last 6 months)
- Bootstrap mechanics
- Merkle incentives
- New staking contracts
- Recently added strategies

### 2. **Complex Math** 
- Reward calculations
- Fee distributions
- Share price calculations
- Multi-token conversions

### 3. **External Integrations**
- Curve pools
- Convex staking
- Balancer LPs
- Aave/Compound lending

### 4. **Governance Mechanisms**
- Voting power calculations
- Proposal execution
- Timelock bypasses
- Emergency procedures

---

## 💡 PRO TIPS

### Tip 1: Focus on Edge Cases
```python
# Test with:
- Zero values
- Maximum uint256 values
- Just above/below thresholds
- First/last user scenarios
- Empty arrays
```

### Tip 2: Chain Multiple Actions
```python
# Often bugs appear when:
1. Deposit
2. Transfer shares
3. Withdraw
4. Repeat

# Or:
1. Stake
2. Vote
3. Unstake  
4. Revote (should fail?)
```

### Tip 3: Read Recent PRs
```python
# Check Yearn GitHub:
- Recently merged PRs (last 3 months)
- Open issues labeled "bug"
- Recently closed issues (might not be fully fixed)
```

### Tip 4: Compare to Similar Protocols
```python
# If Curve had a bug in their staking:
- Check if Yearn's implementation is vulnerable
- Look for similar patterns
```

### Tip 5: Economic Game Theory
```python
# Ask:
- What if everyone does this?
- What if nobody does this?
- What if I do this right before/after X?
- Can I grief other users for profit?
```

---

## 🚀 IMMEDIATE NEXT STEPS

### Step 1: Get the In-Scope Strategy List
```bash
# Install Foundry/Cast
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Query helper contract
cast call 0x5b4F3BE554a88Bd0f8d8769B9260be865ba03B4a \
  "assetsStrategiesAddresses()(address[],address[])" \
  --rpc-url https://eth.llamarpc.com

# This returns ALL in-scope strategies!
```

### Step 2: Clone Yearn Repos
```bash
# veYFI contracts
git clone https://github.com/yearn/veYFI

# yETH contracts  
git clone https://github.com/yearn/yETH

# Latest strategies
git clone https://github.com/yearn/yearn-vaults-v3
```

### Step 3: Set Up Testing Environment
```bash
# Use Brownie or Foundry
pip3 install eth-brownie

# Fork mainnet
brownie console --network mainnet-fork
```

### Step 4: Start with veYFI
```python
# veYFI is complex and newer
# Focus on:
- Voting power manipulation
- Early exit exploits
- Reward claiming bugs
- Lock duration bypass
```

---

## 🎁 BONUS: Automated Scanning

### Use These Tools:
```bash
# Slither (static analysis)
pip3 install slither-analyzer
slither . --print human-summary

# Mythril (symbolic execution)  
pip3 install mythril
myth analyze contract.sol

# Echidna (fuzzing)
docker pull trailofbits/echidna
echidna-test contract.sol
```

---

## 📊 EXPECTED VALUE ANALYSIS

### High-Value Targets (Ranked):

| Contract Type | Audit Coverage | Complexity | Expected Bounty | Time Required |
|--------------|----------------|------------|-----------------|---------------|
| **veYFI** | Medium | High | $50K-$200K | 2-3 weeks |
| **yETH Bootstrap** | Medium | High | $50K-$200K | 2-3 weeks |
| **Merkle Incentives** | Low | Medium | $20K-$100K | 1-2 weeks |
| **New Strategies** | Low | Medium | $20K-$100K | 1-2 weeks |
| **dYFI** | Medium | Medium | $20K-$100K | 1-2 weeks |
| **Old Vaults** | High | High | $0-$20K | Not recommended |

---

## 🎯 MY RECOMMENDATION

### Start Here (In Order):

1. **Week 1-2: veYFI Contract**
   - Most complex
   - Governance bugs = high severity
   - Lock mechanics have edge cases
   
2. **Week 3: Merkle Incentives**
   - Merkle trees are tricky
   - Double-claim bugs common
   - Less audited

3. **Week 4+: Active Strategies**
   - Get list from helper contract
   - Focus on newest ones
   - External integration = more bugs

### Don't Waste Time On:
- ❌ Old vault v2 contracts (too audited)
- ❌ Known donation attacks (disclosed 2021)
- ❌ Simple ERC20 wrappers (no complexity)

---

## 💪 YOU GOT THIS!

**Remember:**
- Yearn is heavily audited, so bugs are HARD to find
- Focus on NEW contracts and COMPLEX interactions
- Be systematic and thorough
- One good bug > ten mediocre reports
- Quality > Quantity

**Expected timeline for a REAL critical bug:**
- 2-4 weeks of dedicated research
- $50K-$200K payout
- Career-making finding

**Good luck! 🚀**
