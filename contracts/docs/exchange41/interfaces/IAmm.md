## `IAmm`

When a user trades on an exchange, the AMM will automatically take the opposite position, effectively
acting like a market maker in a traditional order book market.

An AMM can execute any hedging or arbitraging strategies internally. For example, it can trade with a spot market
such as Uniswap to hedge a position.




### `trade(int256 _assetAmount, int256 _oraclePrice, bool _isClosingTraderPosition) → int256 stableAmount` (external)

Takes a position in token1 against token0. Can only be called by the exchange to take the opposite
position to a trader. The trade can fail for several different reasons: its hedging strategy failed, it has
insufficient funds, out of gas, etc.





### `getAssetPrice() → int256 assetPrice` (external)

Returns the asset price that this AMM quotes for trading with it.







