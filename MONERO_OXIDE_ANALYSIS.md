# 🔍 ANALYZING MONERO OXIDE CODE

## Files Received:
1. ✅ lib.rs (SharedKeyDerivations, crypto)
2. ✅ send/mod.rs (SignableTransaction, validation)
3. ✅ send/tx.rs (Transaction building)
4. ✅ send/multisig.rs (FROST multisig)
5. ✅ scan.rs (Output scanning)
6. ✅ decoys.rs (Decoy selection)

## Searching for Vulnerabilities...

### Category 1: Panic Vulnerabilities (Low Severity)

Looking for unwrap(), expect(), panic!() calls...

#### Finding #1: Potential Integer Underflow Panic in decoys.rs

**Location:** `decoys.rs`, `select_n()` function

**Code:**
```rust
if (iters == MAX_ITERS) ||
    ((highest_output_exclusive_bound -
      u64::try_from(do_not_select.len())
        .expect("amount of ignored decoys exceeds 2^{64}")) <
      u64::from(ring_len))
{
    Err(...)?;
}
```

**Issue:**
If `highest_output_exclusive_bound < do_not_select.len()`, the subtraction will underflow!

With `overflow-checks = true` (which they use), this causes a PANIC!

**Attack Scenario:**
1. Malicious RPC returns low `highest_output_exclusive_bound`
2. Decoy selection tries many outputs
3. `do_not_select` set grows
4. Subtraction underflows
5. PANIC! Wallet crashes

**Impact:** 
- Undocumented panic reachable from public API ✅
- DoS on wallet operations
- User can't send transactions

**Severity:** LOW ($1,000)

Let me find more...

### Category 2: Non-Constant-Time Operations (Low Severity)

Looking for branches on secret data...

#### Finding #2: Potential Timing Leak in SharedKeyDerivations

**Location:** `lib.rs`, `decrypt()` function

**Code:**
```rust
fn decrypt(&self, enc_amount: &EncryptedAmount) -> Commitment {
    match enc_amount {
      EncryptedAmount::Original { mask, amount } => {
        // Different code path
      }
      EncryptedAmount::Compact { amount } => {
        // Different code path
      }
    }
}
```

**Issue:**
The match creates different execution paths based on encrypted amount type. 
If timing can be measured, might leak information about transaction structure.

**BUT:** This is probably NOT secret data - the encrypted amount type is public on-chain.

**Verdict:** Probably not a valid bug.

Let me find something better...

### Category 3: Incorrect Cryptographic Formulas

Need to verify against Monero protocol specs...

Actually, I cannot verify these without the Monero protocol documentation.

### Category 4: Documentation Issues

Looking for undocumented behaviors...

Let me focus on the BEST bug I found...
