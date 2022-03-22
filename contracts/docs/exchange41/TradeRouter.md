## `TradeRouter`






### `constructor(address _exchangeLedger, address _wethToken, address _tokenVault, address _oracle, address _assetToken, address _stableToken)` (public)





### `setOracle(address _oracle)` (external)

Updates the oracle the TokenRouter uses for trades, can only be performed
by the voting executor.



### `getPrice() → int256` (external)

Gets the asset price from the oracle associated to this contract.



### `receive()` (external)

Allow ETH to be sent to this contract for unwrapping WETH only.



### `changePosition(int256 deltaAsset, int256 deltaStable, int256 stableBound) → bytes` (public)

Changes a trader's position.




### `changePositionPacked(uint256 packedData) → bytes` (external)

Changes a trader's position, same as `changePosition`, but using a compacted data representation to save
gas cost.




### `closePosition() → bytes` (external)

Closes the trader's current position.


This helper function is useful to save gas in L2 chains where call data is the dominating cost factor (for
example, Arbitrum).


### `onTokenTransfer(address from, uint256 amount, bytes data) → bool` (external)

Changes a trader's position, using the IERC677 transferAndCall flow on the stable token contract.




### `changePositionWithEth(int256 deltaAsset, int256 deltaStable, int256 stableBound) → bytes` (public)

Changes a trader's position, same as `changePosition`, but allows users to pay their collateral in ETH
instead of WETH (only valid for exchanges that use WETH as collateral).
The value in `deltaStable` needs to match the amount of ETH sent in the transaction.


The ETH received is converted to WETH and stored into the TokenVault. The whole system operates with ERC20,
not ETH.


### `changePositionWithEthPacked(uint256 packed) → bytes` (external)

Changes a trader's position, same as `changePositionWithEth`, but using a compacted data representation
to save gas cost.




### `closePositionWithEth() → bytes` (external)

Closes the trader's current position, and returns ETH instead of WETH in exchanges that use WETH as
collateral.


This helper function is useful to save gas in L2 chains where call data is the dominating cost factor (for
example, Arbitrum).


### `changePositionOnBehalfOf(address trader, int256 deltaAsset, int256 deltaStable, int256 stableBound, bytes32 extraHash, bytes signature) → bytes` (external)

Change's a trader's position, same as in changePosition, but can be called by any arbitrary contract
that the trader trusts.




### `liquidate(address trader) → bytes` (external)

Liquidates `trader` if its position is liquidatable and pays out to the different actors involved (the
liquidator, the pool and the trader).




### `unpack(uint256 packed) → int256 deltaAsset, int256 deltaStable, int256 stableBound` (public)






### `TraderPositionChanged(address trader, int256 deltaAsset, int256 deltaStable, int256 stableBound)`

Emitted when trader's position changed (except if it is the result of a liquidation).



### `TraderLiquidated(address trader, address liquidator)`

Emitted when a `trader` was successfully liquidated by a `liquidator`.



### `PayoutsTransferred(struct IExchangeLedger.Payout[] payouts)`

Emitted when payments to different actors are successfully done.



### `OracleChanged(address oldOracle, address newOracle)`

Emitted when the oracle address changes.




### `ChangePositionInputData`


int256 deltaAsset


int256 stableBound



