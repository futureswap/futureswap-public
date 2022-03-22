## `ExchangeLedger`






### `initialize(address _treasury)` (external)





### `changePosition(address trader, int256 deltaAsset, int256 deltaStable, int256 stableBound, int256 oraclePrice, uint256 time) → struct IExchangeLedger.Payout[], bytes` (external)

Changes a traders position in the exchange.




### `liquidate(address trader, address liquidator, int256 oraclePrice, uint256 time) → struct IExchangeLedger.Payout[], bytes` (external)

Liquidates a trader's position.
For a position to be liquidatable, it needs to either have less collateral (stable) left than
ExchangeConfig.minCollateral or exceed a leverage higher than ExchangeConfig.maxLeverage.
If this is a case, anyone can liquidate the position and receive a reward.




### `getPosition(address trader, int256 price, uint256 time) → int256, int256, uint32` (external)

Position for a particular trader.




### `getAmmPosition(int256 price, uint256 time) → int256 stableAmount, int256 assetAmount` (external)

Returns the position of the AMM in the exchange.




### `setExchangeConfig(struct IExchangeLedger.ExchangeConfig config)` (external)

Updates the config of the exchange, can only be performed by the voting executor.



### `setExchangeState(enum IExchangeLedger.ExchangeState _exchangeState, int256 _pausePrice)` (external)

Update the exchange state.
Is used to PAUSE or STOP the exchange. When PAUSED, trades cannot open, liquidity cannot be added, and a
fixed oracle price is set. When STOPPED no user actions can occur.



### `setHook(address _hook)` (external)

Update the exchange hook.



### `setAmm(address _amm)` (external)

Update the AMM used in the exchange.



### `setTradeRouter(address _tradeRouter)` (external)

Update the TradeRouter authorized for this exchange.





### `Funding`


int256 longAccumulatedFunding


int256 longAsset


int256 shortAccumulatedFunding


int256 shortAsset


### `Position`


int256 asset


int256 stable


### `EntranchedPosition`


int256 trancheShares


int256 stable


uint32 trancheIdx


### `TranchePosition`


struct ExchangeLedger.Position position


int256 totalShares



