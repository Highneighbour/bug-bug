# 🚀 QUICK START: Find Your First Critical Bug

## 🎯 FASTEST PATH TO A BOUNTY

### Option 1: veYFI Voting Power Manipulation (2-3 weeks)

**Why This?**
- Complex voting power calculations
- Multiple edge cases
- Relatively new (2023)
- High bounty potential ($50K-$200K)

**How to Start:**
```bash
# 1. Clone veYFI repo
git clone https://github.com/yearn/veYFI
cd veYFI

# 2. Read the main contract
# Focus on: VotingYFI.sol or veYFI.vy

# 3. Look for these specific bugs:
```

**Specific Attack Vectors to Test:**

```solidity
// A. Early Exit Exploit
// Can you exit lock early without penalty?
stake(amount, LONG_DURATION)
// ... some action ...
exit()  // Should revert or have penalty?

// B. Vote Weight Manipulation  
// Can you double-count votes?
stake_for(user1, amount1)
stake_for(user2, amount2)  
delegate(user1, user2)
// Does user2 now have amount1 + amount2 votes?

// C. Lock Duration Bypass
// Can you get long-lock benefits with short lock?
stake(amount, SHORT_DURATION)
extend_lock(LONG_DURATION)  
// Do you get full rewards instantly?

// D. Reward Draining
// Can you claim more rewards than entitled?
stake(amount)
claim_rewards()
unstake()
stake(amount)  // Reset state?
claim_rewards()  // Claim again?
```

---

### Option 2: Merkle Incentives Double-Claim (1-2 weeks)

**Why This?**
- Merkle trees often have bugs
- Simpler to understand
- Medium-High bounty ($20K-$100K)

**Contract:** `0x05faacC28C27680a9C2727853bEaC27680a5179f`

**How to Test:**
```bash
# 1. Get contract source from Etherscan
# 2. Look for claim() function
# 3. Test these scenarios:
```

**Specific Bugs to Find:**

```solidity
// A. Double Claiming
// Can you claim same reward twice?
claim(proof1, amount1, index1)
claim(proof1, amount1, index1)  // Should revert!

// B. Proof Manipulation
// Can you use someone else's proof?
claim(victim_proof, attacker_address, victim_amount)

// C. Root Update Exploit
// When root updates, can you claim from both?
claim(proof_old_root, amount_old)
// Root updates
claim(proof_new_root, amount_new)
// Got both?

// D. Index Collision
// Can two users have same index?
claim(proof, amount, index=5)  // User A
claim(proof, amount, index=5)  // User B - should fail!
```

---

### Option 3: Strategy Integration Bug (1-2 weeks)

**Why This?**
- Many strategies in scope
- External protocol risks
- Less audited
- High impact ($20K-$100K)

**How to Find Strategy Contracts:**
```python
# Using web3.py or brownie:
from brownie import Contract, web3

helper = Contract("0x5b4F3BE554a88Bd0f8d8769B9260be865ba03B4a")
strategies, vaults = helper.assetsStrategiesAddresses()

# Pick newest strategy (last in array)
latest_strategy = strategies[-1]

# Download source from Etherscan
# Analyze for bugs!
```

**Common Strategy Bugs:**

```solidity
// A. Price Oracle Manipulation
// Can you manipulate external price?
// 1. Flash loan
// 2. Manipulate Curve/Uniswap pool
// 3. Trigger strategy action at bad price
// 4. Profit

// B. Slippage Exploit
// Does strategy have proper slippage protection?
harvest()  // Triggers swap
// Front-run with large trade
// Strategy gets bad price
// Profit from sandwich

// C. Reentrancy in Harvest
// Does harvest() have external calls?
harvest() {
    external_protocol.withdraw()  // <-- Reenter here?
    update_accounting()
}

// D. Emergency Exit Bypass
// Can you bypass emergency restrictions?
emergency_shutdown()
// ... some action ...
deposit()  // Should fail!
```

---

## 🛠️ TOOLS YOU NEED

### Install These NOW:

```bash
# 1. Foundry (for testing)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 2. Python + Brownie (alternative)
pip3 install eth-brownie

# 3. Slither (static analysis)
pip3 install slither-analyzer

# 4. Node + Hardhat (if needed)
npm install -g hardhat
```

---

## 📝 TESTING TEMPLATE

Save this as `test_exploit.py`:

```python
from brownie import Contract, accounts, web3

def test_double_claim():
    """Test if Merkle contract allows double claiming"""
    
    # Setup
    attacker = accounts[0]
    contract = Contract("0x05faacC28C27680a9C2727853bEaC27680a5179f")
    
    # Proof and amount (get from actual Merkle tree)
    proof = [...]  # Merkle proof
    amount = 1000 * 10**18
    index = 1
    
    # First claim
    tx1 = contract.claim(proof, amount, index, {"from": attacker})
    balance_after_first = attacker.balance()
    
    # Try to claim again
    try:
        tx2 = contract.claim(proof, amount, index, {"from": attacker})
        balance_after_second = attacker.balance()
        
        if balance_after_second > balance_after_first:
            print("🚨 CRITICAL: DOUBLE CLAIM POSSIBLE!")
            print(f"Claimed twice: {balance_after_second - balance_after_first}")
            return True
    except:
        print("✓ Double claim prevented")
        return False
```

---

## 🎯 YOUR 30-DAY PLAN

### Week 1: Setup & Learning
- [ ] Install all tools
- [ ] Clone Yearn repos
- [ ] Read veYFI code
- [ ] Set up local fork
- [ ] Run basic tests

### Week 2: Deep Dive veYFI
- [ ] Test voting power edge cases
- [ ] Try lock duration bypasses
- [ ] Test reward calculations
- [ ] Look for reentrancy
- [ ] Try delegation bugs

### Week 3: Merkle Incentives
- [ ] Test double-claim
- [ ] Try proof manipulation
- [ ] Test root updates
- [ ] Look for index bugs
- [ ] Test access controls

### Week 4: Strategy Hunting
- [ ] Get strategy list
- [ ] Pick 3 newest strategies
- [ ] Test price manipulation
- [ ] Test slippage bugs
- [ ] Test reentrancy

---

## 💰 EXPECTED OUTCOMES

**Realistic Timeline:**
- **Week 1:** Learning, no bugs found
- **Week 2:** 1-2 low/medium bugs found
- **Week 3:** Possible high severity bug
- **Week 4:** Critical bug if you're thorough

**Bounty Expectations:**
- Low bugs: $1K-$5K each
- Medium: $5K-$20K each  
- High: $20K-$100K each
- Critical: $100K-$200K

**Most Likely Outcome:**
- Find 2-3 medium bugs in month 1
- Total payout: $10K-$40K
- One critical bug if lucky: $50K-$200K

---

## 🚨 RED FLAGS THAT YOU FOUND A BUG

### You likely found something if:

✅ **Function reverts unexpectedly**
```python
# If this works when it shouldn't:
claim_after_deadline()  # Should revert!
```

✅ **Balance increases mysteriously**
```python
balance_before = 100
do_action()
balance_after = 150  # Expected 100!
```

✅ **State becomes inconsistent**
```python
total_staked = 1000
user_stakes = [300, 300, 300, 300]  # Sum = 1200!
```

✅ **Privilege bypass**
```python
# Non-admin can call admin function
contract.setFees(0, {"from": regular_user})  # Should fail!
```

✅ **Reentrancy succeeds**
```python
# Call same function while first call still executing
withdraw() -> callback -> withdraw()  # Got double!
```

---

## 📚 RESOURCES

### Must-Read:
- Yearn Security: https://github.com/yearn/yearn-security
- Previous Audits: Check `/audits` folder
- Known Issues: Check `/disclosures` folder

### Communities:
- Yearn Discord: discord.gg/yearn
- Immunefi Discord: discord.gg/immunefi
- Twitter: Follow @yearnfi @immunefi

---

## 🎯 START NOW!

**Your first task (next 1 hour):**

1. Clone veYFI repo
2. Find the main staking contract
3. Read the `stake()` function
4. Identify 3 potential edge cases
5. Write tests for them

**GO! ⏰**
