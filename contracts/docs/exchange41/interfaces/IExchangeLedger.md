## `IExchangeLedger`

An API for an exchange that manages leveraged trades for one pair of tokens.  One token
is called "asset" and it's address is returned by `assetToken()`. The other token is called
"stable" and it's address is returned by `stableToken()`.  Exchange is mostly symmetrical with
regard to how "asset" and "stable" are treated.

The exchange only deals with abstract accounting. It requires a trusted setup with a TokenRouter
to do actual transfers of ERC20's. The two basic operations are

 - Trade: Implemented by `changePosition()`, requires collateral to be deposited by caller.
 - Liquidation bot(s): Implemented by `liquidate()`.





### `exchangeState() → enum IExchangeLedger.ExchangeState` (external)

Returns the current state of the exchange. See description on ExchangeState for details.



### `pausePrice() → int256` (external)

Returns the price that exchange was paused at.
If the exchange got paused, this price overrides the oracle price for liquidations and liquidity
providers redeeming their liquidity.



### `amm() → contract IAmm` (external)

Address of the amm this exchange calls to take the opposite of trades.



### `changePosition(address trader, int256 deltaStable, int256 deltaAsset, int256 stableBound, int256 oraclePrice, uint256 time) → struct IExchangeLedger.Payout[], bytes` (external)

Changes a traders position in the exchange.




### `liquidate(address trader, address liquidator, int256 oraclePrice, uint256 time) → struct IExchangeLedger.Payout[], bytes` (external)

Liquidates a trader's position.
For a position to be liquidatable, it needs to either have less collateral (stable) left than
ExchangeConfig.minCollateral or exceed a leverage higher than ExchangeConfig.maxLeverage.
If this is a case, anyone can liquidate the position and receive a reward.




### `getPosition(address trader, int256 price, uint256 time) → int256 asset, int256 stable, uint32 trancheIdx` (external)

Position for a particular trader.




### `getAmmPosition(int256 price, uint256 time) → int256 stableAmount, int256 assetAmount` (external)

Returns the position of the AMM in the exchange.




### `setExchangeConfig(struct IExchangeLedger.ExchangeConfig _config)` (external)

Updates the config of the exchange, can only be performed by the voting executor.



### `setExchangeState(enum IExchangeLedger.ExchangeState _state, int256 _pausePrice)` (external)

Update the exchange state.
Is used to PAUSE or STOP the exchange. When PAUSED, trades cannot open, liquidity cannot be added, and a
fixed oracle price is set. When STOPPED no user actions can occur.



### `setHook(address _hook)` (external)

Update the exchange hook.



### `setAmm(address _amm)` (external)

Update the AMM used in the exchange.



### `setTradeRouter(address _tradeRouter)` (external)

Update the TradeRouter authorized for this exchange.




### `PositionChanged(struct IExchangeLedger.ChangePositionData cpd)`

Emitted on all trades/liquidations containing all information of the update.




### `ExchangeConfigChanged(struct IExchangeLedger.ExchangeConfig previousConfig, struct IExchangeLedger.ExchangeConfig newConfig)`

Emitted when exchange config is updated.



### `ExchangeStateChanged(enum IExchangeLedger.ExchangeState previousState, int256 previousPausePrice, enum IExchangeLedger.ExchangeState newState, int256 newPausePrice)`

Emitted when the exchange state is updated.




### `ExchangeHookAddressChanged(address previousHook, address newHook)`

Emitted when exchange hook is updated.



### `AmmAddressChanged(address previousAmm, address newAmm)`

Emitted when AMM used by the exchange is updated.



### `TradeRouterAddressChanged(address previousTradeRouter, address newTradeRouter)`

Emitted when the TradeRouter authorized by the exchange is updated.



### `AmmAdl(int256 deltaAsset, int256 deltaStable)`

Emitted when an ADL happens against the pool.




### `OnChangePositionHookFailed(string reason, struct IExchangeLedger.ChangePositionData cpd)`

Emitted if the hook call fails.




### `TrancheAutoDeleveraged(uint8 tranche, uint32 trancheIdx, int256 assetADL, int256 stableADL, int256 totalTrancheShares)`

Emmitted when a tranche is ADL'd.





### `Payout`


address to


uint256 amount


### `ChangePositionData`


address trader


address liquidator


bool isClosing


int256 deltaAsset


int256 deltaStable


int256 stableBound


int256 oraclePrice


uint256 time


int256 timeFeeCharged


int256 dfrCharged


int256 tradeFee


int256 startAsset


int256 startStable


int256 totalAsset


int256 totalStable


int256 traderPayment


int256 liquidatorPayment


int256 treasuryPayment


int256 executionPrice


### `ExchangeConfig`


int256 tradeFeeFraction


int256 timeFee


uint256 maxLeverage


uint256 minCollateral


int256 treasuryFraction


int256 dfrRate


int256 liquidatorFrac


int256 maxLiquidatorFee


int256 poolLiquidationFrac


int256 maxPoolLiquidationFee


int256 adlFeePercent



### `ExchangeState`











