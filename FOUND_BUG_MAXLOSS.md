# 🚨 POTENTIAL BUG FOUND: Withdrawal Loss Check Bypass

## The Vulnerability

In the `withdraw()` function, the loss tolerance check can be bypassed in edge cases:

```vyper
@external
def withdraw(
    maxShares: uint256 = MAX_UINT256,
    recipient: address = msg.sender,
    maxLoss: uint256 = 1,  # Default 0.01%
) -> uint256:
    # ... withdrawal logic ...
    
    # Loss check:
    assert totalLoss <= maxLoss * (value + totalLoss) / MAX_BPS
```

## Mathematical Flaw

The formula `maxLoss * (value + totalLoss) / MAX_BPS` can allow higher losses than intended.

**Example:**
- User expects max 1% loss (maxLoss = 100)
- value = 1000 tokens
- totalLoss = 500 tokens (actual 33% loss!)

Check: `500 <= 100 * (1000 + 500) / 10000`
       `500 <= 100 * 1500 / 10000`
       `500 <= 15,000 / 10000`
       `500 <= 15` ❌ This SHOULD fail

Wait, that's not right. Let me recalculate...

Actually, the math checks out. This isn't a bug.

Let me look for something else...
