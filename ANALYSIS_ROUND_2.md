# 🔍 DEEPER ANALYSIS - Finding Novel Bugs

## Issue #1: Locked Profit - Might Be By Design
The overwrite behavior might be intentional (only lock latest harvest).
Verdict: ❌ Probably not a bug

## Let me look for OTHER vulnerabilities...

## Issue #2: _reportLoss Debt Ratio Manipulation

```vyper
@internal
def _reportLoss(strategy: address, loss: uint256):
    totalDebt: uint256 = self.strategies[strategy].totalDebt
    assert totalDebt >= loss
    self.strategies[strategy].totalLoss += loss
    self.strategies[strategy].totalDebt = totalDebt - loss
    self.totalDebt -= loss

    # ⚠️ SUSPICIOUS: Automatically reduces debtRatio on loss
    debtRatio: uint256 = self.strategies[strategy].debtRatio
    ratio_change: uint256 = min(loss * MAX_BPS / self._totalAssets(), debtRatio)
    self.strategies[strategy].debtRatio -= ratio_change 
    self.debtRatio -= ratio_change
```

**Potential Issue:**
- Loss automatically reduces strategy's debtRatio
- Could be gamed: Report small losses to reduce allocation
- Then manager/gov has to manually re-increase
- Griefing attack vector?

## Issue #3: Withdrawal Loss Tolerance

```vyper
@external
def withdraw(maxShares: uint256, recipient: address, maxLoss: uint256 = 1):
    # maxLoss default is 0.01% (1 basis point)
    # ...
    assert totalLoss <= maxLoss * (value + totalLoss) / MAX_BPS
```

**Potential Issue:**
- Default 1 BPS (0.01%) loss tolerance might be too high
- Users might not realize they're accepting losses
- Could be exploited during volatile market conditions

## Issue #4: Strategy Migration

```vyper
@external
def migrateStrategy(oldVersion: address, newVersion: address):
    assert msg.sender == self.governance
    # ...
    Strategy(oldVersion).migrate(newVersion)
```

**Issue:**
- No validation of newVersion strategy
- Could migrate to malicious strategy
- Trust in governance (but that's expected)

## Issue #5: Fee Calculation Overflow

```vyper
governance_fee: uint256 = (
    (self.totalDebt * (block.timestamp - self.lastReport) * self.managementFee)
    / MAX_BPS
    / SECS_PER_YEAR
)
```

**Potential Issue:**
- If lastReport is ancient (vault inactive for years)
- Multiplication could overflow
- But Vyper 0.2.8 has overflow protection...

Let me find something REAL...
