# 🚨 CRITICAL PRE-SUBMISSION CHECKLIST

## ⚠️ DO NOT SUBMIT UNTIL YOU VERIFY ALL OF THESE

### 1. CONTRACT VERIFICATION (CRITICAL!)

**You MUST verify the contract at 0x986b4AFF588a109c09B50A03f42E4110E29D353F actually has this vulnerability!**

#### Step 1: Check the Contract Source Code

Go to: https://etherscan.io/address/0x986b4AFF588a109c09B50A03f42E4110E29D353F#code

**Verify:**
- [ ] Contract is verified on Etherscan (source code visible)
- [ ] Contract is actually a Yearn Vault
- [ ] Contract name/type matches what you're claiming
- [ ] You can see the share calculation logic
- [ ] The vulnerability pattern exists in THIS specific contract

**How to check:**
1. Click "Contract" tab on Etherscan
2. Look for the source code
3. Search for deposit/mint functions
4. Verify share calculation formula exists
5. Confirm NO virtual shares offset exists
6. Confirm NO minimum deposit requirement exists

#### Step 2: Verify Contract is In-Scope

**Check if this contract is actually covered by Yearn's bug bounty:**

1. Go to helper contract: https://etherscan.io/address/0x437758D475F70249e03EDa6bE23684aD1FC375F0#readContract
2. Call `assetsAddresses()` function
3. Check if `0x986b4AFF588a109c09B50A03f42E4110E29D353F` is in the returned list

**Critical Questions:**
- [ ] Is this contract in the returned list?
- [ ] If NO, is this contract mentioned anywhere in Yearn's scope?
- [ ] If NO, are you relying on "case-by-case" exception?

⚠️ **If contract is NOT in scope, your submission may be rejected!**

#### Step 3: Check Contract Activity

1. Go to: https://etherscan.io/address/0x986b4AFF588a109c09B50A03f42E4110E29D353F
2. Check:
   - [ ] Contract has actual TVL (Total Value Locked)
   - [ ] Contract has recent transactions
   - [ ] Contract is actively used
   - [ ] Contract is NOT deprecated

⚠️ **If contract is deprecated/unused, bounty may be reduced to $0!**

---

### 2. VULNERABILITY VERIFICATION

**Before submitting, you MUST prove the vulnerability exists in THIS specific contract:**

#### Required Checks:

- [ ] **Read the actual deployed contract code** (not just source repo)
- [ ] **Verify share calculation formula** matches your analysis
- [ ] **Confirm NO protections exist**:
  - No VIRTUAL_SHARES constant
  - No VIRTUAL_ASSETS constant  
  - No MINIMUM_LIQUIDITY requirement
  - No dead shares burned on init
  - No minimum first deposit check
- [ ] **Test on local fork** (optional but recommended)

#### How to Verify:

```bash
# Using cast to check contract code
cast code 0x986b4AFF588a109c09B50A03f42E4110E29D353F --rpc-url https://eth.llamarpc.com

# Check for virtual shares (should return error if doesn't exist)
cast call 0x986b4AFF588a109c09B50A03f42E4110E29D353F "VIRTUAL_SHARES()(uint256)" --rpc-url https://eth.llamarpc.com
```

If you get an error on the VIRTUAL_SHARES call, that's GOOD - it means no protection exists.

---

### 3. SUBMISSION CONTENT REVIEW

Your submission looks **technically sound**, but verify:

#### Title ✅
```
First Depositor Attack via Share Price Manipulation Leads to Complete Theft of User Funds
```
- Clear, descriptive, mentions impact

#### Description ✅
- Brief/Intro: Clear and concise
- Vulnerability Details: Comprehensive
- Impact Details: Well-justified
- References: Appropriate

#### Proof of Concept ✅
- Working Python simulation
- Demonstrates the attack
- Shows victim gets 0 shares
- Calculates profit correctly

#### Severity Classification ✅
- Critical: Correct
- Impact: Direct theft of user funds ✓

---

### 4. CRITICAL WARNINGS

#### Warning #1: Contract Specificity

Your submission assumes this contract has the vulnerability.

**Did you actually:**
- [ ] Read the contract source code at that address?
- [ ] Verify the vulnerable pattern exists?
- [ ] Confirm no mitigations are present?

⚠️ **If you submit without verifying, you risk:**
- Immediate rejection
- Potential ban for spam/low-quality reports
- Reputation damage on Immunefi

#### Warning #2: Scope Verification

**The contract MUST be in-scope or your report will be rejected!**

From Yearn's program:
> "Yearn provides helper contracts to list the actual contracts that are considered in scope"

**Did you verify this specific address is in scope?**

If NOT in the returned list, you're relying on:
> "Other contracts, outside of the ones mentioned here, might be considered on a case by case basis, as long as economic damage can be achieved."

This is **NOT guaranteed** - they may reject out-of-scope submissions.

#### Warning #3: Known Issue Risk

**Has this vulnerability been reported before?**

Check:
- [ ] Yearn's audit reports (in /workspace/yearn-vaults-v3/audits/)
- [ ] Yearn's GitHub issues
- [ ] Previous Immunefi submissions (if accessible)
- [ ] Public disclosures

⚠️ **If this is a known issue, you will NOT receive a bounty!**

---

### 5. FINAL VERIFICATION STEPS

Before clicking Submit:

#### A. Contract Address
- [ ] Triple-check: 0x986b4AFF588a109c09B50A03f42E4110E29D353F
- [ ] Verified on Etherscan
- [ ] Source code visible
- [ ] Actually a Yearn vault

#### B. Scope Status  
- [ ] Confirmed in-scope OR
- [ ] Have strong case-by-case argument

#### C. Vulnerability Exists
- [ ] Read actual deployed code
- [ ] Confirmed vulnerable pattern
- [ ] No mitigations present
- [ ] Not a known issue

#### D. Submission Quality
- [ ] All sections complete
- [ ] PoC code provided
- [ ] References included
- [ ] No typos/errors

#### E. Realistic Expectations
- [ ] Understand bounty is $20K-$200K (NOT $500K-$1M)
- [ ] Prepared to wait 1-2 weeks for response
- [ ] Ready to provide more info if asked
- [ ] Understand rejection is possible

---

### 6. IF YOU HAVEN'T VERIFIED THE CONTRACT...

### 🚨 STOP - DO NOT SUBMIT YET! 🚨

**You MUST verify the contract first!**

**Go to Etherscan NOW:**
https://etherscan.io/address/0x986b4AFF588a109c09B50A03f42E4110E29D353F#code

**Check:**
1. Is source code verified and visible?
2. What is the contract name?
3. What functions does it have?
4. Can you see the share calculation logic?
5. Does the vulnerability actually exist?

**If you cannot answer these questions with confidence, DO NOT SUBMIT!**

---

### 7. ALTERNATIVE: REQUEST HELP

If you're unsure about the contract, consider:

1. **Ask Yearn Team**: Tweet @iearnfinance asking if this contract is in-scope
2. **Check Discord**: Join Yearn Discord and ask in security channel
3. **Start with Question**: Submit as a question first, not a vulnerability

---

### 8. SUBMISSION DECISION TREE

```
Is contract verified on Etherscan?
├─ NO → DO NOT SUBMIT (can't verify vulnerability)
└─ YES → Continue

Is contract in the scope list from helper contract?
├─ NO → Is it mentioned in bug bounty page?
│   ├─ NO → HIGH RISK - May be rejected
│   └─ YES → Continue
└─ YES → Continue

Have you read the ACTUAL deployed contract code?
├─ NO → STOP - Read it first!
└─ YES → Continue

Does the vulnerable pattern exist in the code?
├─ NO → DO NOT SUBMIT (no vulnerability)
├─ UNSURE → DO NOT SUBMIT (verify first)
└─ YES → Continue

Are there any protections (virtual shares, min deposit, etc.)?
├─ YES → DO NOT SUBMIT (vulnerability is mitigated)
├─ UNSURE → DO NOT SUBMIT (verify first)
└─ NO → Continue

Is this a known issue from audits?
├─ YES → DO NOT SUBMIT (won't get bounty)
├─ UNSURE → Check audits first
└─ NO → Continue

All checks passed?
└─ YES → SUBMIT!
```

---

## ✅ IF ALL CHECKS PASS

### You're Ready to Submit If:

1. ✅ Contract is verified on Etherscan
2. ✅ Contract is in-scope (confirmed via helper contract)
3. ✅ You've read the actual deployed code
4. ✅ Vulnerability exists in deployed code
5. ✅ No mitigations are present
6. ✅ Not a known issue
7. ✅ Contract is actively used
8. ✅ All submission sections are complete

### Expected Timeline:
- Day 0: Submit
- Day 1-3: Initial review
- Day 3-7: Technical verification
- Day 7-14: Bounty decision
- Day 14-30: Payment (if approved)

### Expected Bounty:
- Best case: $100,000 - $200,000
- Likely: $50,000 - $100,000
- Minimum: $20,000
- Worst case: $0 (if rejected)

---

## ❌ IF ANY CHECKS FAIL

### DO NOT SUBMIT

**Submitting without proper verification risks:**
- Immediate rejection as spam
- Account suspension/ban
- Reputation damage
- Wasted time

**Instead:**
1. Complete all verification steps
2. Read the actual contract code
3. Confirm vulnerability exists
4. Verify scope status
5. Then submit

---

## 📞 NEED HELP?

If unsure about any of these checks:
- Review contract code carefully
- Ask in Yearn Discord
- Request clarification via Immunefi support
- Wait and verify rather than submit prematurely

---

**REMEMBER**: Quality > Speed

A well-verified, accurate submission is worth much more than a quick, unverified one.

Take the time to verify everything before submitting!
