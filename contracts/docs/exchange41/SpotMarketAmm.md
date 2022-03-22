## `SpotMarketAmm`

This AMM takes the opposite position to the aggregate trader positions on the Futureswap
exchange (can be 0 if trader longs and shorts are perfectly balanced). This AMM hedges its position by taking an
opposite position on an external market and thus ideally stay market neutral. Example: aggregate trader position
on the Futureswap exchange is long 200 asset tokens. The AMM's position there would be short 200 asset token. But
it also has a 200 asset long position on the external spot market. This allows it to make the fees without being
exposed to market risks (relatively to LPs' original 50:50 allocation in value between stable:asset).


This AMM should never directly hold funds and should send any tokens directly to the token vault.

### `atomicTradingExecution()`






### `constructor(address _wethToken)` (public)





### `receive()` (external)

Allow ETH to be sent to this contract for unwrapping WETH only.



### `initialize(address _exchangeLedger, address _tokenVault, address _assetToken, address _stableToken, address _liquidityToken, address _liquidityIncentives, address _ammAdapter, address _oracle, struct SpotMarketAmm.AmmConfig _ammConfig)` (external)





### `getAssetPrice() → int256 assetPrice` (external)

Returns the asset price that this AMM quotes for trading with it.




### `trade(int256 assetAmount, int256 assetPrice, bool isClosingTraderPosition) → int256 stableAmount` (external)

Takes a position in token1 against token0. Can only be called by the exchange to take the opposite
position to a trader. The trade can fail for several different reasons: its hedging strategy failed, it has
insufficient funds, out of gas, etc.





### `sendPayment(address recipient, address token0, address token1, int256 amount0Owed, int256 amount1Owed)` (external)

Adapter callback for collecting payment. Only one of the two tokens, stable or asset, can be positive,
which indicates a payment due. Negative indicates we'll receive that token as a result of the swap.
Implementations of this method should protect against malicious calls, and ensure that payments are triggered
only by authorized contracts or as part of a valid trade flow.




### `addLiquidity(int256 stableAmount, int256 maxAssetAmount) → int256` (external)

Add liquidity to the AMM
Callers are expected to have approved the AMM with sufficient limits to pay for the stable/asset required
for adding liquidity.

When calculating the liquidity pool value, we convert value of the "asset" tokens
into the "stable" tokens, using price provided by the price oracle.





### `onTokenTransfer(address, uint256 amount, bytes data) → bool success` (external)

Receive transfer of LP token and allow LP to remove liquidity. Data is expected to contain an encoded
version of `RemoveLiquidityData`.

AMM will determine the split between asset and stable that a liquidity provider receives based on an internal
state. But the total value will always be equal to the share of the total assets owned by the AMM, based on the
share of the provided liquidity tokens.


Called by a token to indicate a transfer into the callee


### `setAmmConfig(struct SpotMarketAmm.AmmConfig _ammConfig)` (public)

Updates the config of the AMM, can only be performed by the voting executor.



### `setOracle(address _oracle)` (external)

Updates the oracle the AMM uses to compute prices for adding/removing liquidity, can only be performed
by the voting executor.



### `setAmmAdapter(address _ammAdapter)` (external)

Allows voting executor to change the amm adapter. This can effectively change the spot market this AMM
trades with.



### `setLiquidityIncentives(address _liquidityIncentives)` (external)

Allows voting executor to change the liquidity incentives.



### `getLiquidityTokenAmount(int256 stableAmount) → int256 assetAmount, int256 liquidityTokenAmount` (external)

Returns the amount of asset required to provide a given stableAmount. Also
returns the number of liquidity tokens that currently would be minted for the stableAmount and assetAmount.




### `getLiquidityValue(int256 liquidityTokenAmount) → int256 assetAmount, int256 stableAmount` (external)

Returns the amounts of stable and asset the given amount of liquidity token owns.



### `getRedeemableLiquidityTokenAmount() → int256` (external)

Returns the number of liquidity token amount that can be redeemed given current AMM positions.
Since the AMM actively uses liquidity to swap with spot markets, the amount of remaining asset or stable tokens
is potentially less than originally provided by LPs. Therefore, not 100% shares are redeemable at any point in
time.



### `ammBalance(int256 price) → int256 ammStableBalance, int256 ammAssetBalance` (public)

Returns the AMM's balance of the stable / asset tokens in the vault.




### `LiquidityAdded(address provider, int256 assetAmount, int256 stableAmount, int256 liquidityTokenAmount, int256 liquidityTokenSupply)`

Emitted when liquidity is added by a liquidity provider




### `LiquidityRemoved(address provider, int256 assetAmount, int256 stableAmount, int256 liquidityTokenAmount, int256 liquidityTokenSupply)`

Emitted when liquidity is removed by a liquidity provider




### `OracleChanged(address oldOracle, address newOracle)`





### `AmmConfigChanged(struct SpotMarketAmm.AmmConfig oldConfig, struct SpotMarketAmm.AmmConfig newConfig)`





### `AmmAdapterChanged(address oldAmmAdapter, address newAmmAdapter)`





### `LiquidityIncentivesChanged(address oldLiquidityIncentives, address newLiquidityIncentives)`






### `AmmConfig`


int256 removeLiquidityFee


int256 tradeLiquidityReserveFactor


### `RemoveLiquidityData`


address receiver


int256 minAssetAmount


int256 minStableAmount


bool useEth



