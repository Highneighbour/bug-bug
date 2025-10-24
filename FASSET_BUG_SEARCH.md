# 🔍 FASSET BUG SEARCH - ANALYSIS IN PROGRESS

## Current Findings:

### 1. Private Key Caching Without Secure Memory Management
**File:** `packages/fasset-bots-core/src/underlying-chain/WalletKeys.ts`

**Issue:** Private keys are cached in memory in the `privateKeyCache` Map but never explicitly cleared or zero'd out.

```typescript
export class DBWalletKeys implements IWalletKeys {
    private privateKeyCache = new Map<string, string>();
    
    async getKey(address: string): Promise<string | undefined> {
        if (!this.privateKeyCache.has(address)) {
            const wa = await this.em.findOne(WalletAddressEntity, { address });
            if (wa != null) {
                const privateKey = this.decryptPrivateKey(wa.encryptedPrivateKey);
                this.privateKeyCache.set(address, privateKey);  // ⚠️ Stored in memory
            }
        }
        return this.privateKeyCache.get(address);
    }
}
```

**Problems:**
- Private keys remain in memory indefinitely
- No explicit cleanup mechanism
- Could be exposed through memory dumps
- Could be swapped to disk if system runs low on memory

**Severity:** Likely LOW/MEDIUM (Not directly exploitable, but poor practice)

---

### 2. Error Object Passed to Logger
**File:** `packages/fasset-bots-core/src/underlying-chain/WalletKeys.ts:68`

```typescript
catch (error) {
    logger.error("Error decrypting database private key...", error);
    //                                                     ^^^^^ Error object logged
}
```

**Potential Issue:** The `error` object from decryption failure is logged. If the error contains sensitive data (partial keys, encrypted keys, etc.), it could be exposed in logs.

**Severity:** Likely LOW (depends on what's in the error object)

---

### 3. Windows Security Bypass
**File:** `packages/fasset-bots-core/src/config/secrets.ts:105-110`

```typescript
function checkFilePermissions(fpath: string): void {
    if (process.platform === "win32") {
        if (process.env.ALLOW_SECRETS_ON_WINDOWS === "true") return; // ⚠️ Bypass
        throw new CommandLineError("Cannot reliably check secrets file permissions on Windows...");
    }
    // ... permission checks for Unix
}
```

**Issue:** On Windows, setting `ALLOW_SECRETS_ON_WINDOWS=true` completely bypasses permission checks for the secrets file.

**Severity:** LOW (Documented behavior, user must opt-in)

---

## Need to Find:

Looking for CRITICAL/HIGH bugs:

1. **Private Key Exfiltration**
   - [ ] Keys logged to console/files
   - [ ] Keys sent to external APIs
   - [ ] Keys exposed in error messages

2. **Fund Theft Vectors**
   - [ ] Transaction manipulation
   - [ ] Unauthorized withdrawals
   - [ ] Collateral bypass

3. **Bot Failures Leading to Loss**
   - [ ] Race conditions
   - [ ] Deadlocks
   - [ ] Uncaught exceptions

## Next Steps:

1. Check `formatArgs` function - does it redact private keys?
2. Look at transaction submission code
3. Check API interaction code
4. Look for race conditions in bot logic
5. Check error handling in critical paths

## Current Status:

Found 3 potential issues, but all LOW severity.
Need to find CRITICAL or HIGH to be worth submitting.

Continuing search...
