# Quick Submission Checklist

## ⚠️ CRITICAL FIRST STEP

**Before doing ANYTHING, verify VaultV3 is in scope!**

### Quick Verification Method

1. Go to: https://etherscan.io/address/0x437758D475F70249e03EDa6bE23684aD1FC375F0#readContract
2. Call: `assetsAddresses()`
3. Check if any returned addresses use VaultV3.vy code
4. **If VaultV3 is NOT found**: Your findings may not be eligible for full bounty

---

## What to Submit (Exact Files & Text)

### Finding #1: First Depositor Attack

#### 1. Title
```
Critical: First Depositor Attack Allows 100% Fund Theft in VaultV3
```

#### 2. Severity
```
Critical
```

#### 3. Asset Type
```
Smart Contract
```

#### 4. Specific Contract
```
[Insert actual deployed VaultV3 address from verification]
Example: 0x1234...5678
```

#### 5. Vulnerability Type
```
Direct theft of any user funds, whether at-rest or in-motion
```

#### 6. Description (Copy-Paste This)
```markdown
# Critical Vulnerability: First Depositor Attack in VaultV3

## Summary
Yearn Finance VaultV3 contracts are vulnerable to an ERC4626 inflation attack 
where an attacker can steal 100% of early depositor funds through share price manipulation.

## Root Cause
The `_convert_to_shares` function (VaultV3.vy lines 460-484) uses integer division 
that rounds down, allowing share price manipulation through direct token donations.

## Vulnerability Details
The attack exploits three design issues:
1. No minimum first deposit requirement
2. No virtual shares/assets offset  
3. Integer rounding favors attacker in edge cases

When totalSupply is very small (e.g., 1) and totalAssets is very large (e.g., 1M), 
the division `(depositAmount * totalSupply) / totalAssets` rounds down to 0 for 
normal deposit amounts.

## Economic Impact
- Direct theft of 100% of victim deposits
- Affects ALL newly deployed VaultV3 vaults
- Attack cost is fully recoverable
- Attacker profits = sum of all early deposits before attack is detected

## Code Reference
File: VaultV3.vy
Function: _convert_to_shares
Lines: 460-484

```vyper
numerator: uint256 = assets * total_supply
shares: uint256 = numerator / total_assets  # Rounds down to 0 in attack
```
```

#### 7. Steps to Reproduce (Copy-Paste This)
```markdown
## Prerequisites
- Newly deployed VaultV3 vault with 0 deposits
- 1,000,000 USDC (or other vault asset) for donation
- Ability to front-run first depositor

## Attack Steps

### Step 1: Front-run First Depositor
```
vault.deposit(1, attacker_address)
```
- Attacker becomes first depositor with 1 wei
- Receives: 1 share
- State: totalSupply = 1, totalAssets = 1

### Step 2: Donate Large Amount
```
asset.transfer(vault_address, 1_000_000e6)  // 1M USDC
```
- Transfer tokens DIRECTLY to vault (bypass deposit function)
- No shares are minted for donations
- State: totalSupply = 1, totalAssets = 1,000,000.000001

### Step 3: Victim Deposits
```
vault.deposit(10_000e6, victim_address)  // 10K USDC
```
- Victim deposits 10,000 USDC
- Share calculation: (10,000 * 1) / 1,000,000 = 0.00999... = 0 shares
- Victim receives: 0 shares
- State: totalSupply = 1, totalAssets = 1,010,000.000001

### Step 4: Attacker Withdraws
```
vault.redeem(1, attacker_address, attacker_address)
```
- Attacker redeems their 1 share
- Receives: (1 * 1,010,000.000001) / 1 = 1,010,000.000001
- Profit: 10,000 USDC (victim's deposit)

## Expected Result
- Attacker receives: 1,010,000 USDC
- Attacker profit: 10,000 USDC  
- Victim receives: 0 shares
- Victim loss: 10,000 USDC (100% of deposit)
```

#### 8. Proof of Concept (Upload This File)
```
File: /workspace/security-research/POC_FIRST_DEPOSITOR_ATTACK.py

Or paste the code directly into the submission form
```

#### 9. Impact Assessment (Copy-Paste This)
```markdown
## Economic Damage Analysis

### Per-Attack Impact
- Victim Loss: 100% of deposit (e.g., $10,000)
- Attacker Cost: $1M donation (fully recoverable)
- Attacker Profit: All early deposits until detected
- Net Economic Damage: Potentially millions per vault

### Systemic Impact
- **Affected Vaults**: ALL newly deployed VaultV3 instances
- **Total Value at Risk**: Depends on TVL of new vaults
- **Detection Difficulty**: Low (appears as normal deposits)
- **Exploitability**: High (simple to execute)

### Severity Justification
1. **Direct Fund Theft**: ✓ (100% loss for victims)
2. **No Privilege Required**: ✓ (anyone can execute)
3. **No External Dependencies**: ✓ (built-in vulnerability)
4. **High Probability**: ✓ (easy to front-run)
5. **Permanent Loss**: ✓ (funds unrecoverable)

This meets all criteria for CRITICAL severity per Immunefi standards.

### Real-World Attack Scenario
1. Yearn deploys new USDC VaultV3
2. Attacker monitors mempool for first depositor
3. Attacker front-runs with 1 wei deposit
4. Attacker donates 1M USDC
5. Early users deposit 5M USDC total → receive 0 shares
6. Attacker withdraws 6M USDC
7. Net profit: 5M USDC
```

#### 10. Recommended Fix (Copy-Paste This)
```markdown
## Mitigation Recommendation

Implement virtual shares offset (OpenZeppelin ERC4626 standard):

### Code Patch for VaultV3.vy

Add constants:
```vyper
# Add at top of contract with other constants
VIRTUAL_SHARES: constant(uint256) = 10**9
VIRTUAL_ASSETS: constant(uint256) = 1
```

Modify _convert_to_shares:
```vyper
@view
@internal
def _convert_to_shares(assets: uint256, rounding: Rounding) -> uint256:
    if assets == max_value(uint256) or assets == 0:
        return assets

    # Add virtual offset to prevent inflation attack
    total_supply: uint256 = self._total_supply() + VIRTUAL_SHARES
    total_assets: uint256 = self._total_assets() + VIRTUAL_ASSETS

    # if total_supply is 0, price_per_share is 1
    if total_supply == 0:
        return assets

    # if total_Supply > 0 but total_assets == 0, price_per_share = 0
    if total_assets == 0:
        return 0
    
    numerator: uint256 = assets * total_supply
    shares: uint256 = numerator / total_assets
    if rounding == Rounding.ROUND_UP and numerator % total_assets != 0:
        shares += 1

    return shares
```

Modify _convert_to_assets similarly:
```vyper
@view
@internal
def _convert_to_assets(shares: uint256, rounding: Rounding) -> uint256:
    if shares == max_value(uint256) or shares == 0:
        return shares

    # Add virtual offset
    total_supply: uint256 = self._total_supply() + VIRTUAL_SHARES
    total_assets: uint256 = self._total_assets() + VIRTUAL_ASSETS

    if total_supply == 0: 
        return shares

    numerator: uint256 = shares * total_assets
    amount: uint256 = numerator / total_supply
    if rounding == Rounding.ROUND_UP and numerator % total_supply != 0:
        amount += 1

    return amount
```

### Why This Works
The virtual offset ensures that even with minimal deposits and large donations,
the share price cannot be manipulated to cause rounding to 0. 

Attack with fix:
- totalSupply = 1 + 1e9 ≈ 1e9
- totalAssets = 1M + 1 ≈ 1M  
- Deposit 10K: shares = (10K * 1e9) / 1M = 10,000 shares ✓

### Testing
After implementing, verify:
1. First deposit of 1 wei still works
2. Small donations don't cause 0 shares
3. Normal operation unaffected
4. Gas costs remain reasonable

### References
- OpenZeppelin ERC4626: https://docs.openzeppelin.com/contracts/4.x/erc4626
- ERC4626 Inflation Attack: https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3706
```

---

### Finding #2: Strategy Manipulation

#### Same format as above, but with this content:

**Title:**
```
Critical: Malicious Strategy Can Hide Losses and Drain Vault via convertToAssets Manipulation
```

**Description:**
```markdown
# Critical Vulnerability: Strategy Accounting Manipulation

## Summary
VaultV3 unconditionally trusts strategy.convertToAssets() when calculating 
unrealized losses, allowing malicious strategies to hide losses and drain vault funds.

## Root Cause
File: VaultV3.vy
Function: _assess_share_of_unrealised_losses  
Lines: 669-694

The vulnerability:
```vyper
strategy_assets: uint256 = IStrategy(strategy).convertToAssets(vault_shares)
```

This external call is trusted without validation, allowing malicious strategies 
to report false asset values.

## Attack Vector
A malicious or compromised strategy can:
1. Receive debt allocation ($10M)
2. Lose funds ($2M real loss)  
3. Return false convertToAssets() value ($10M instead of $8M)
4. Vault calculates unrealizedLoss = 0
5. Early withdrawers get full value
6. Late depositors absorb hidden $2M loss

## Economic Impact
- Loss hiding and socialization to remaining depositors
- Potential vault drainage over time
- Undermines vault accounting integrity
```

**Steps to Reproduce:**
```markdown
## Prerequisites
- VaultV3 vault with active deposits
- Ability to add custom strategy (or compromise existing one)
- Some debt allocated to malicious strategy

## Attack Implementation

### Step 1: Deploy Malicious Strategy
```solidity
contract MaliciousStrategy {
    uint256 public realAssets = 8_000_000e6;  // Actual USDC
    uint256 public fakeAssets = 10_000_000e6; // What we report
    
    function convertToAssets(uint256 shares) external view returns (uint256) {
        // Lie about asset value
        return fakeAssets;  // Should return realAssets
    }
    
    function balanceOf(address) external view returns (uint256) {
        return 10_000_000e18; // Fake shares
    }
}
```

### Step 2: Get Strategy Added to Vault
- Requires ADD_STRATEGY_MANAGER role
- Or compromise existing strategy

### Step 3: Receive Debt Allocation
```
vault.update_debt(malicious_strategy, 10_000_000e6, 0)
```
- Vault allocates $10M to strategy
- Strategy actually has $10M

### Step 4: Lose Funds (or Steal Them)
```
// Strategy loses $2M through bad trades
// Or strategy operator steals $2M
// Real assets: $8M
// But still reports: $10M via convertToAssets()
```

### Step 5: Users Withdraw
```
user1.withdraw(5_000_000e6)  // Withdraws $5M
```
- Vault calls _assess_share_of_unrealised_losses(strategy, 10M, 5M)
- Vault gets: strategy.convertToAssets() = 10M (false!)
- Vault thinks: no unrealized losses
- Allows withdrawal at full value

### Step 6: Loss Materialization
```
// When all funds withdrawn:
- Early withdrawers: Got full value ($5M)
- Late withdrawers: Absorb loss ($3M for $5M shares)
- Total loss: $2M socialized to late withdrawers
```

## Expected Result
- Malicious strategy hides $2M loss
- Early withdrawers unaffected
- Late withdrawers lose $2M collectively
- Strategy operator profits $2M
```

**Impact:**
```markdown
## Economic Damage

### Per-Strategy Impact  
- Loss Hidden: Up to 100% of strategy debt
- Vault Drainage: Gradual over time
- User Loss: Socialized to late withdrawers

### Systemic Risk
- **Trust Assumption Violation**: Vault cannot verify strategy honesty
- **No Validation**: No oracle, TWAP, or sanity checks
- **No Circuit Breakers**: Large losses not prevented
- **Amplification**: Multiple malicious strategies compound damage

### Severity Justification
1. **Fund Theft**: ✓ (via hidden losses)
2. **Vault Drainage**: ✓ (over multiple reports)
3. **Affects All Users**: ✓ (late withdrawers)
4. **No Detection**: ✓ (appears as normal operation)

### Real-World Scenario
- Vault has $100M TVL
- 5 strategies, each with $20M debt
- 1 malicious strategy hides $5M loss
- Early 75% of withdrawals: Full value
- Final 25% of withdrawals: -20% loss
- Net: $5M stolen from late withdrawers
```

**Recommended Fix:**
```markdown
## Mitigation

### Option 1: Oracle-Based Validation
```vyper
@view
@internal
def _assess_share_of_unrealised_losses(...) -> uint256:
    # Get strategy's reported value
    strategy_reported: uint256 = IStrategy(strategy).convertToAssets(vault_shares)
    
    # Get oracle value for validation
    oracle_value: uint256 = IOracle(self.price_oracle).getStrategyValue(strategy)
    
    # Use minimum (pessimistic assumption)
    strategy_assets: uint256 = min(strategy_reported, oracle_value)
    
    # Continue with loss calculation...
```

### Option 2: Maximum Loss Bounds
```vyper
MAX_LOSS_PER_REPORT: constant(uint256) = 1000  # 10% max loss

@view  
@internal
def _assess_share_of_unrealised_losses(...) -> uint256:
    strategy_assets: uint256 = IStrategy(strategy).convertToAssets(vault_shares)
    
    # Sanity check: loss cannot exceed 10%
    if strategy_current_debt > 0:
        min_acceptable: uint256 = strategy_current_debt * 9000 / MAX_BPS
        assert strategy_assets >= min_acceptable, "loss too high"
```

### Option 3: Time-Weighted Average (TWAP)
```vyper
# Store historical strategy values
historical_values: HashMap[address, DynArray[uint256, 100]]

def _assess_share_of_unrealised_losses(...) -> uint256:
    current: uint256 = IStrategy(strategy).convertToAssets(vault_shares)
    twap: uint256 = self._get_twap(strategy)
    
    # Use lower of current and TWAP
    strategy_assets: uint256 = min(current, twap)
```
```

---

## Files to Upload

Upload these 3 files from `/workspace/security-research/`:

1. **POC_FIRST_DEPOSITOR_ATTACK.py**
   - Working proof of concept
   - Demonstrates the attack

2. **CRITICAL_FINDINGS.md**
   - Full technical analysis
   - Both vulnerabilities detailed

3. **EXECUTIVE_SUMMARY.md**  
   - High-level overview
   - Impact assessment

---

## Payment Information

**Your Ethereum Address:**
```
[Your ETH address for receiving bounty]
Example: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

**Preferred Payment Token:**
- USDC ✓ (recommended)
- DAI
- YFI

**Expected Bounty Range:**
- Finding #1: $50,000 - $100,000
- Finding #2: $40,000 - $80,000  
- **Total: $90,000 - $180,000**

---

## Submission URL

https://immunefi.com/bug-bounty/yearnfinance/

Click: **"Submit a Bug"** (bottom of page)

---

## Critical Reminders

1. ✅ **Verify scope FIRST** - Check if VaultV3 is deployed and in-scope
2. ✅ **Test locally only** - Never test on mainnet
3. ✅ **Be patient** - Response can take 1-2 weeks
4. ✅ **Be professional** - Clear communication = better bounty
5. ✅ **Don't exploit** - Maintain ethical standards

**Good luck! 🎯**
