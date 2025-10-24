# Analyzing specific vulnerable functions from the source

# FUNCTION 1: _shareValue - Locked Profit Calculation
@view
@internal
def _shareValue(shares: uint256) -> uint256:
    lockedFundsRatio: uint256 = (block.timestamp - self.lastReport) * self.lockedProfitDegration
    freeFunds: uint256 = self._totalAssets()

    if(lockedFundsRatio < DEGREDATION_COEFFICIENT):
        freeFunds -= (self.lockedProfit - (lockedFundsRatio * self.lockedProfit / DEGREDATION_COEFFICIENT))
    # NOTE: using 1e3 for extra precision here, when decimals is low
    return ((10 ** 3 * (shares * freeFunds)) / self.totalSupply) / 10 ** 3

# FUNCTION 2: report - Strategy Reporting
@external
def report(gain: uint256, loss: uint256, _debtPayment: uint256) -> uint256:
    assert self.strategies[msg.sender].activation > 0
    assert self.token.balanceOf(msg.sender) >= gain + _debtPayment

    if loss > 0:
        self._reportLoss(msg.sender, loss)

    self._assessFees(msg.sender, gain)
    self.strategies[msg.sender].totalGain += gain

    # ... debt calculations ...
    
    self.strategies[msg.sender].lastReport = block.timestamp
    self.lastReport = block.timestamp
    self.lockedProfit = gain # ⚠️ SUSPICIOUS: Just sets to gain?

# FUNCTION 3: _assessFees
@internal
def _assessFees(strategy: address, gain: uint256):
    governance_fee: uint256 = (
        (self.totalDebt * (block.timestamp - self.lastReport) * self.managementFee)
        / MAX_BPS
        / SECS_PER_YEAR
    )
    strategist_fee: uint256 = 0

    if gain > 0:
        strategist_fee = (gain * self.strategies[strategy].performanceFee) / MAX_BPS
        governance_fee += gain * self.performanceFee / MAX_BPS

    total_fee: uint256 = governance_fee + strategist_fee
    if total_fee > 0:
        reward: uint256 = self._issueSharesForAmount(self, total_fee)
        # ...

