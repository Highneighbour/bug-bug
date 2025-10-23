# Yearn Finance Bug Bounty Submission Guide

## ⚠️ CRITICAL: Scope Verification Required First

Before submitting, you MUST verify the findings are in scope.

---

## STEP 1: Verify VaultV3 is In-Scope

### 1.1 Check Deployed Vaults

The Immunefi program states:
> "Yearn provides helper contracts to list the actual contracts that are considered in scope"

**Helper Contract Addresses:**

| Network | StrategiesHelper | AddressesGeneratorV2Vaults |
|---------|-----------------|----------------------------|
| Ethereum | `0x5b4F3BE554a88Bd0f8d8769B9260be865ba03B4a` | `0x437758D475F70249e03EDa6bE23684aD1FC375F0` |
| Fantom | `0x97D0bE2a72fc4Db90eD9Dbc2Ea7F03B4968f6938` | `0x8ca27a3ab8917a033f278D20135d2467faA099bA` |
| Optimism | `0xD3A93C794ee2798D8f7906493Cd3c2A835aa0074` | `0xD63aB09ac2048a7eCac92f0fFad5F104edD0E032` |
| Arbitrum | `0x66a1a27f4b22dcaa24e427dcffbf0cddd9d35e0f` | `0x3a8efa2d87d60c0289f19b44a0928f4269c0f094` |

### 1.2 Query In-Scope Contracts

You need to call these functions:
```
StrategiesHelper.assetsStrategiesAddresses()
AddressesGeneratorV2Vaults.assetsAddresses()
```

**How to do this:**

**Option A: Using Etherscan**
1. Go to https://etherscan.io/address/0x437758D475F70249e03EDa6bE23684aD1FC375F0#readContract
2. Find `assetsAddresses()` function
3. Click "Query" to get list of in-scope vault addresses
4. Check if any addresses use VaultV3.vy code

**Option B: Using Cast (Command Line)**
```bash
# Ethereum mainnet
cast call 0x437758D475F70249e03EDa6bE23684aD1FC375F0 "assetsAddresses()(address[])" --rpc-url https://eth.llamarpc.com

# Then check each returned address
cast code <VAULT_ADDRESS> --rpc-url https://eth.llamarpc.com
```

**Option C: Using Web3.py**
```python
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('https://eth.llamarpc.com'))
helper = w3.eth.contract(
    address='0x437758D475F70249e03EDa6bE23684aD1FC375F0',
    abi=[{
        "inputs": [],
        "name": "assetsAddresses",
        "outputs": [{"type": "address[]"}],
        "stateMutability": "view",
        "type": "function"
    }]
)

vaults = helper.functions.assetsAddresses().call()
print("In-scope vaults:", vaults)

# Check each vault's code
for vault in vaults:
    code = w3.eth.get_code(vault)
    print(f"{vault}: {len(code)} bytes")
```

### 1.3 Verify VaultV3 Usage

For each vault address returned:
1. Check the contract source on Etherscan
2. Look for VaultV3.vy or similar code
3. Verify the vulnerability exists in the deployed version

**If VaultV3 is NOT in scope:**
- The findings may not be eligible for bounty
- But you can still report under "case-by-case" exception
- Include: "Other contracts, outside of the ones mentioned here, might be considered on a case by case basis, as long as economic damage can be achieved."

---

## STEP 2: Prepare Submission Package

### 2.1 Required Documents

Based on Immunefi requirements, prepare:

**1. Vulnerability Description**
```markdown
# Critical Vulnerability: First Depositor Attack in VaultV3

## Summary
Yearn Finance VaultV3 contracts are vulnerable to an ERC4626 inflation 
attack that allows attackers to steal 100% of early depositor funds through 
share price manipulation.

## Severity
CRITICAL - Direct theft of user funds

## Affected Contracts
[List specific deployed addresses from Step 1]
- Contract: VaultV3.vy
- Location: Lines 460-484 (_convert_to_shares)
- Network: Ethereum [or other]
```

**2. Steps to Reproduce**
```markdown
## Attack Steps

### Prerequisites
- Newly deployed VaultV3 vault with no deposits
- 1,000,000 USDC for donation (fully recoverable)

### Execution

1. Front-run first depositor:
   - Call vault.deposit(1, attacker_address)
   - Receive: 1 share
   
2. Donate to inflate share price:
   - Transfer 1,000,000 USDC directly to vault contract
   - Do NOT use deposit() function
   - Share price now: 1,000,000:1
   
3. Wait for victim deposit:
   - Victim calls vault.deposit(10,000 USDC, victim_address)
   - Victim receives: 0 shares (due to rounding down)
   - Victim's funds now in vault
   
4. Withdraw stolen funds:
   - Call vault.redeem(1, attacker_address, attacker_address)
   - Receive: ~1,010,000 USDC
   - Profit: 10,000 USDC (victim's deposit)
```

**3. Proof of Concept**
Submit the Python PoC:
```python
# Include: /workspace/security-research/POC_FIRST_DEPOSITOR_ATTACK.py
```

**4. Impact Assessment**
```markdown
## Economic Impact

### Direct Impact
- Complete loss of funds for early depositors
- 100% theft rate (victim loses entire deposit)
- Attacker cost: Fully recoverable (donation returned + profit)

### Scale
- Affects: ALL VaultV3 deployments
- Risk Level: CRITICAL
- Exploitability: HIGH (easy to execute)
- Detection: LOW (appears as normal deposits)

### Financial Impact
Per Attack:
- Attacker investment: 1,000,000 USDC (recoverable)
- Potential profit: ALL early deposits
- Expected profit: $10,000 - $1,000,000 per attack

Systemic Risk:
- All new VaultV3 vaults are vulnerable
- Protocol reputation damage
- Loss of user trust
```

**5. Recommended Fix**
```markdown
## Mitigation

Implement virtual shares offset (OpenZeppelin ERC4626 approach):

```vyper
# Add to VaultV3.vy
VIRTUAL_SHARES: constant(uint256) = 10**9
VIRTUAL_ASSETS: constant(uint256) = 1

@view
@internal
def _convert_to_shares(assets: uint256, rounding: Rounding) -> uint256:
    if assets == 0:
        return 0
    
    total_supply: uint256 = self._total_supply() + VIRTUAL_SHARES
    total_assets: uint256 = self._total_assets() + VIRTUAL_ASSETS
    
    numerator: uint256 = assets * total_supply
    shares: uint256 = numerator / total_assets
    
    if rounding == Rounding.ROUND_UP and numerator % total_assets != 0:
        shares += 1
    
    return shares
```

This prevents the attack by ensuring share price cannot be manipulated 
to extreme values.
```

### 2.2 Additional Files to Include

From `/workspace/security-research/`:
1. ✅ POC_FIRST_DEPOSITOR_ATTACK.py (proof of concept)
2. ✅ CRITICAL_FINDINGS.md (full technical details)
3. ✅ EXECUTIVE_SUMMARY.md (overview)

---

## STEP 3: Submit via Immunefi

### 3.1 Create Account
1. Go to https://immunefi.com/
2. Click "Sign Up" (top right)
3. Complete registration
4. Verify email

### 3.2 Access Submission Form

1. Navigate to https://immunefi.com/bug-bounty/yearnfinance/
2. Click **"Submit a Bug"** button (bottom of page)
3. Login if prompted

### 3.3 Fill Out Submission Form

**Field-by-Field Guide:**

**Title:**
```
Critical: First Depositor Attack Allows 100% Fund Theft in VaultV3
```

**Severity:**
- Select: **Critical**

**Asset:**
- Select the specific VaultV3 address you verified in Step 1
- If not listed, choose "Other" and specify the contract address

**Vulnerability Type:**
- Select: **Direct theft of any user funds**

**Description:**
Paste your vulnerability description from Step 2.1 item #1

**Steps to Reproduce:**
Paste from Step 2.1 item #2

**Proof of Concept:**
```
Option 1: Paste the Python code directly
Option 2: Upload POC_FIRST_DEPOSITOR_ATTACK.py as attachment
Option 3: Link to GitHub gist (if you create one)
```

**Impact:**
Paste the impact assessment from Step 2.1 item #4

**Remediation:**
Paste the recommended fix from Step 2.1 item #5

**Attachments:**
Upload:
- POC_FIRST_DEPOSITOR_ATTACK.py
- CRITICAL_FINDINGS.md
- EXECUTIVE_SUMMARY.md
- Screenshots if applicable

**Email:**
Your contact email (can be anonymous email)

**Ethereum Address for Payment:**
Your ETH address to receive bounty (if awarded)

---

## STEP 4: For Second Vulnerability (Strategy Manipulation)

Submit separately following same process:

**Title:**
```
Critical: Malicious Strategy Can Hide Losses and Drain Vault
```

**Description:**
```markdown
# Critical Vulnerability: Strategy Accounting Manipulation

## Summary
VaultV3 blindly trusts strategy.convertToAssets() when calculating 
unrealized losses, allowing malicious strategies to hide losses and 
drain vault funds.

## Affected Code
- File: VaultV3.vy
- Function: _assess_share_of_unrealised_losses
- Lines: 669-694

## Attack Vector
A malicious strategy can:
1. Receive debt allocation from vault (e.g., $10M)
2. Lose funds in reality (e.g., $2M loss)
3. Report false convertToAssets() value ($10M instead of $8M)
4. Vault calculates 0 unrealized losses
5. Early withdrawers get full value
6. Remaining depositors absorb hidden $2M loss
```

Include similar structure as Finding #1.

---

## STEP 5: Communication Timeline

### What to Expect

**Day 0-1: Submission**
- You submit via Immunefi
- Receive confirmation email
- Ticket number assigned

**Day 1-3: Initial Review**
- Immunefi reviews for completeness
- May ask clarifying questions
- Forwards to Yearn team

**Day 3-7: Technical Review**
- Yearn security team evaluates
- May request additional PoC
- May ask for live demonstration

**Day 7-14: Severity Assessment**
- Team determines severity level
- Calculates potential bounty
- May negotiate amount

**Day 14-30: Decision**
- Bounty approved/denied
- Amount confirmed
- Payment terms agreed

**Day 30-60: Payment**
- Patch development (if needed)
- Bounty payment processed
- Paid in USDC/DAI/YFI to your address

### Response Protocol

**If they ask for more details:**
- Respond within 24 hours
- Provide requested information
- Offer to demonstrate live (if safe)

**If they dispute severity:**
- Refer to impact documentation
- Provide additional evidence
- Calculate economic damage clearly

**If they claim "known issue":**
- Ask for proof (previous disclosure)
- Check if it's in their audit reports
- Verify if it's truly identical

---

## STEP 6: Bounty Expectations

### Realistic Bounty Range

Based on Yearn's actual program:

**Finding #1 (First Depositor Attack):**
- **Severity**: Critical ✓
- **Impact**: Direct theft of user funds ✓
- **Expected Bounty**: $20,000 - $200,000
- **Most Likely**: $50,000 - $100,000
- **Depends on**: 
  - Number of vulnerable vaults
  - Total value at risk
  - Ease of exploitation

**Finding #2 (Strategy Manipulation):**
- **Severity**: Critical ✓
- **Impact**: Vault drainage ✓
- **Expected Bounty**: $20,000 - $200,000
- **Most Likely**: $40,000 - $80,000
- **Depends on**:
  - Whether malicious strategy could be added
  - Existing strategy vetting process
  - Actual economic impact

**Total Expected**: $60,000 - $280,000 (both findings)

### Factors That Affect Payout

**Increase Payout:**
- ✅ Clear economic damage demonstrated
- ✅ Multiple vaults affected
- ✅ Easy to exploit
- ✅ No existing mitigations
- ✅ High quality PoC

**Decrease Payout:**
- ❌ Requires privileged access
- ❌ External dependencies
- ❌ Low likelihood
- ❌ Mitigations exist
- ❌ Only affects test/deprecated contracts

---

## IMPORTANT NOTES

### Scope Verification is CRITICAL

**You MUST verify:**
1. ✅ VaultV3 is actually deployed on mainnet
2. ✅ Deployed version matches the code analyzed
3. ✅ Contract is actively used (has TVL)
4. ✅ Contract is in the in-scope list

**If VaultV3 is NOT in scope:**
- You can still submit under "case-by-case" exception
- Include strong economic impact analysis
- May receive lower bounty or be declined
- Be prepared for this possibility

### Ethical Requirements

**You MUST NOT:**
- ❌ Exploit the vulnerability yourself
- ❌ Test on mainnet (use local fork)
- ❌ Disclose publicly before resolution
- ❌ Share with other researchers
- ❌ Use for financial trading

**You MUST:**
- ✅ Use responsible disclosure
- ✅ Cooperate with team
- ✅ Maintain confidentiality
- ✅ Test only on local fork
- ✅ Follow up professionally

### Legal Compliance

By submitting, you agree:
- You discovered this independently
- You have not exploited it
- You will not disclose for 90 days
- You comply with bug bounty ToS
- You conducted ethical research

---

## TROUBLESHOOTING

### "Contract not in scope"
**Solution**: Use the "case-by-case" exception clause and emphasize economic damage

### "Already known"
**Solution**: Ask for proof, check audit reports, verify it's identical

### "Not reproducible"
**Solution**: Provide more detailed PoC, offer live demo, add screenshots

### "Low severity"
**Solution**: Provide economic impact analysis, show real-world attack scenario

### "No response"
**Solution**: Wait 7 days, then follow up via Immunefi support

---

## CHECKLIST BEFORE SUBMITTING

### Verification
- [ ] Confirmed VaultV3 is in scope (Step 1)
- [ ] Identified specific vulnerable contract addresses
- [ ] Verified vulnerability in deployed code
- [ ] Tested PoC locally (not on mainnet!)

### Documentation
- [ ] Clear vulnerability description
- [ ] Step-by-step reproduction steps
- [ ] Working proof of concept
- [ ] Economic impact analysis
- [ ] Recommended fix

### Submission
- [ ] Created Immunefi account
- [ ] Filled out all required fields
- [ ] Uploaded all attachments
- [ ] Provided ETH address for payment
- [ ] Double-checked for accuracy

### Ethics
- [ ] Have not exploited vulnerability
- [ ] Have not tested on mainnet
- [ ] Have not disclosed publicly
- [ ] Will maintain confidentiality
- [ ] Conducted research ethically

---

## SUBMISSION TEMPLATES

### Email Template (if needed)

```
Subject: Critical Vulnerability Disclosure - VaultV3 First Depositor Attack

Dear Yearn Security Team,

I am writing to responsibly disclose a critical vulnerability in Yearn's 
VaultV3 contracts that allows complete theft of user funds.

Vulnerability: First Depositor / Donation Attack (ERC4626 Inflation)
Severity: CRITICAL
Impact: 100% loss of early depositor funds

I have submitted full details via Immunefi (Ticket #XXXXX) including:
- Detailed vulnerability description
- Step-by-step reproduction
- Working proof of concept
- Recommended mitigation

I am available for any clarifications and can provide a live demonstration 
if needed.

This disclosure follows responsible disclosure guidelines. I will maintain 
confidentiality and have not exploited this vulnerability.

Best regards,
[Your Name/Handle]
Immunefi Ticket: #XXXXX
```

---

## FINAL ADVICE

1. **Verify scope first** - Don't waste time if VaultV3 isn't deployed
2. **Be patient** - Responses can take days/weeks
3. **Be professional** - Clear communication increases bounty
4. **Be persistent** - Follow up if no response after 7 days
5. **Be realistic** - Expect $60K-$280K, not $1M

**Good luck with your submission!**
