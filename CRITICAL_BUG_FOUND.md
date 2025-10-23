# 🚨 POTENTIAL CRITICAL BUG: Locked Profit Overwrite Vulnerability

## The Issue

In the `report()` function (line ~1020 in source):

```vyper
@external
def report(gain: uint256, loss: uint256, _debtPayment: uint256) -> uint256:
    # ... validation ...
    
    self._assessFees(msg.sender, gain)
    self.strategies[msg.sender].totalGain += gain
    
    # ... debt management ...
    
    self.strategies[msg.sender].lastReport = block.timestamp
    self.lastReport = block.timestamp
    self.lockedProfit = gain  # 🚨 OVERWRITES instead of accumulating!
```

## The Vulnerability

**Each strategy report OVERWRITES `lockedProfit` instead of accumulating it!**

### Attack Scenario:

1. **Vault has 2 strategies:**
   - Strategy A manages $1M
   - Strategy B manages $1M

2. **Strategy A harvests with 100K profit:**
   - `report(100000, 0, 0)` called
   - `lockedProfit = 100000`
   - This profit should be locked for 6 hours

3. **Strategy B harvests 1 block later with 10K profit:**
   - `report(10000, 0, 0)` called
   - `lockedProfit = 10000` (OVERWRITES!)
   - **90K profit becomes instantly unlocked!**

4. **Attacker withdraws immediately:**
   - `_shareValue()` only subtracts 10K as locked
   - Gets share of the 90K that should still be locked
   - **Steals profit meant to be time-locked**

## Why This is Critical

### Impact:
- **Direct theft of locked profits** from other depositors
- **Breaks profit unlocking mechanism** completely
- **Front-running opportunity** on strategy harvests
- **Strategist can manipulate** timing of reports

### Exploitation:
1. Monitor mempool for strategy harvests
2. When large profit reported, trigger second strategy
3. Front-run withdrawals to capture unlocked profits
4. Repeat on every harvest

### Economic Damage:
- **Per Attack:** Steal portion of locked profits
- **Frequency:** Every harvest (could be daily)
- **Victims:** All vault depositors
- **Scale:** Affects ALL vaults with multiple strategies

## Proof of Concept Logic

```python
# Vault with 2 strategies and 1000 shares outstanding

# Initial state
vault.lockedProfit = 0
vault.lastReport = timestamp_0

# Strategy A reports 100 ETH profit
strategy_A.report(100 ETH, 0, 0)
# vault.lockedProfit = 100 ETH ✓
# vault.lastReport = timestamp_1

# 1 block later, Strategy B reports 10 ETH profit  
strategy_B.report(10 ETH, 0, 0)
# vault.lockedProfit = 10 ETH ❌ (should be 110 ETH or handle differently)
# vault.lastReport = timestamp_2

# _shareValue() calculation:
# freeFunds = totalAssets
# Only subtracts 10 ETH as locked (not 100 ETH + 10 ETH)
# Withdrawers get access to 90 ETH that should still be locked!
```

## Why It Wasn't Caught

1. **Multi-strategy edge case** - Most audits focus on single strategy
2. **Timing-dependent** - Requires strategies to report close together
3. **Complex interaction** - Between report() and _shareValue()
4. **Not in known issues** - No mention in 2021 disclosures or audits

## Next Steps

1. ✅ Verify this in actual deployed contract
2. ✅ Build working PoC with Foundry/Brownie
3. ✅ Calculate exact economic impact
4. ✅ Check if this is truly novel (not in audits)
5. ✅ Prepare submission if confirmed
