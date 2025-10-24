# 🎯 MONERO OXIDE BUG HUNTING - DETAILED STEP-BY-STEP

## PHASE 1: GET THE CODE (30 minutes)

### Step 1.1: Clone the Repository
```bash
# Open your terminal
cd ~/
git clone https://github.com/monero-oxide/monero-oxide
cd monero-oxide
```

### Step 1.2: Understand the Structure
```bash
# List the main directories
ls -la

# You should see:
# - wallet/ (wallet implementation)
# - crypto/ (cryptographic primitives)
# - networks/ (network types)
# - etc.
```

### Step 1.3: Find the Core Files
```bash
# List wallet files
ls -la wallet/src/

# Find the main transaction building code
find . -name "*.rs" | grep -E "transaction|sign|key|proof"
```

### Step 1.4: Copy Key Files to Me

**Run this command:**
```bash
# Get the main wallet files
cat wallet/src/lib.rs > ~/wallet_lib.txt
cat wallet/src/transaction.rs > ~/transaction.txt 2>/dev/null || echo "File not found"
cat wallet/src/sign.rs > ~/sign.txt 2>/dev/null || echo "File not found"

# Then copy-paste the contents to me
```

**IMPORTANT:** Don't just send me links. Copy-paste the actual Rust code.

---

## PHASE 2: I ANALYZE THE CODE (2-4 hours)

### What I'll Do:

Once you give me the actual Rust code, I'll look for:

1. **Panic conditions** (Low severity)
   - Unwrap() calls
   - Expect() without proper checks
   - Division by zero
   - Array indexing without bounds checking

2. **Non-constant-time operations** (Low severity)
   - Timing attacks on secret data
   - Branches on secret values
   - Variable-time operations

3. **Incorrect cryptographic formulas** (Low-High severity)
   - Wrong curve operations
   - Incorrect proof generation
   - Invalid signature schemes

4. **Key recovery issues** (Critical severity)
   - Private key leaks
   - Seed phrase vulnerabilities
   - Key derivation bugs

### What You'll Get from Me:

- List of 5-10 suspicious code sections
- Specific attack vectors to test
- Detailed testing instructions
- Expected vs actual behavior

---

## PHASE 3: YOU TEST THE FINDINGS (1-2 days)

### Step 3.1: Set Up Testing Environment

```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Verify installation
rustc --version
cargo --version
```

### Step 3.2: Build the Project

```bash
cd ~/monero-oxide

# Build with tests
cargo build --all-features

# Run existing tests
cargo test --all-features
```

### Step 3.3: Test Each Bug I Found

For each vulnerability I identify, I'll give you:

**Example Testing Template:**
```rust
// Test for panic vulnerability
#[test]
fn test_panic_on_zero_input() {
    // Setup
    let wallet = Wallet::new();
    
    // Try to trigger panic
    let result = wallet.some_function(0);
    
    // Check if it panics
    // Expected: Should handle gracefully
    // Actual: Might panic!
}
```

You'll run:
```bash
# Add my test to tests/ directory
# Run it
cargo test test_panic_on_zero_input
```

### Step 3.4: Confirm the Bug

For each bug I find, verify:
- [ ] Code location is correct
- [ ] Bug is reproducible
- [ ] Impact is real
- [ ] Not in known issues
- [ ] Not in audit reports

---

## PHASE 4: CHECK KNOWN ISSUES (1 hour)

### Step 4.1: Read Audit Reports

```bash
cd ~/monero-oxide/audits
ls -la

# Read the Cypher Stack audit
# Look for your bug
# If found → DON'T SUBMIT
```

### Step 4.2: Check GitHub Issues

```bash
# Search for related issues
# Go to: https://github.com/monero-oxide/monero-oxide/issues

# Search for keywords related to your bug
# If found → DON'T SUBMIT
```

### Step 4.3: Check Cuprate and Serai Issues

From the program rules:
> "https://github.com/monero-oxide/monero-oxide/issues
> https://github.com/Cuprate/cuprate/issues
> https://github.com/serai-dex/serai/issues"

**Check ALL three!**

---

## PHASE 5: BUILD THE SUBMISSION (2-3 hours)

### Step 5.1: Write Clear Description

I'll help you write:
- Clear title
- Detailed description
- Root cause explanation
- Impact analysis

### Step 5.2: Create Working PoC

You'll provide:
- Rust test case that demonstrates the bug
- Command to run it
- Expected vs actual output
- Clear evidence of impact

### Step 5.3: Verify Scope

**CRITICAL - Don't skip this!**

- [ ] Monero Oxide is in scope ✅
- [ ] Impact type matches Immunefi list
- [ ] Severity matches your claim
- [ ] Not in known issues
- [ ] Not in audit reports

---

## PHASE 6: SUBMIT (10 minutes)

### Step 6.1: Fill Form Carefully

1. Asset: monero-oxide (main branch)
2. Impact: (Match to Immunefi's list exactly)
3. Severity: (Match your evidence)
4. Title: (I'll provide)
5. Description: (I'll provide)
6. PoC: (Your working Rust test)

### Step 6.2: Triple-Check Before Submit

- [ ] Scope verified ✅
- [ ] Bug is real ✅
- [ ] PoC works ✅
- [ ] Not in known issues ✅
- [ ] Clear description ✅

### Step 6.3: Submit

Click submit and wait.

---

## ESTIMATED TIMELINE

- **Phase 1** (Get code): 30 minutes
- **Phase 2** (I analyze): 2-4 hours
- **Phase 3** (You test): 1-2 days
- **Phase 4** (Check known): 1 hour
- **Phase 5** (Build submission): 2-3 hours
- **Phase 6** (Submit): 10 minutes

**TOTAL: 2-3 days minimum**

---

## SUCCESS PROBABILITY

If we follow this process:
- 50-60% chance of finding a valid bug
- 70-80% chance it's accepted if found
- Overall: 35-50% success rate
- Expected bounty: $1,000 - $10,000

**Much better than rushing and getting banned!**

---

## WHAT I NEED FROM YOU RIGHT NOW

### DO THIS NOW:

```bash
# 1. Clone the repo
git clone https://github.com/monero-oxide/monero-oxide
cd monero-oxide

# 2. Get the main wallet files
cat wallet/src/lib.rs

# 3. Copy-paste the output here
# (The FULL file contents)

# 4. Also copy these if they exist:
cat wallet/src/transaction.rs
cat wallet/src/send.rs
cat wallet/src/address.rs
```

### Then Paste Here:

```
[PASTE THE RUST CODE HERE]
```

**Once I have the ACTUAL code, I can:**
- Analyze it properly
- Find real bugs
- Give you specific test steps
- Help you submit successfully

---

## I WILL NOT PROCEED WITHOUT THE ACTUAL CODE

I learned from my mistakes. I will NOT:
- ❌ Guess bugs based on documentation
- ❌ Analyze code I can't see
- ❌ Give you something to submit without verification
- ❌ Risk getting you banned again

I WILL:
- ✅ Analyze actual code you provide
- ✅ Find real vulnerabilities
- ✅ Give you detailed test instructions
- ✅ Help verify before submission

---

**Your move: Clone the repo and paste the code here.** 🎯
