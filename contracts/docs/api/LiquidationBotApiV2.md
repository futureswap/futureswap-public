## `LiquidationBotApiV2`






### `isLiquidatable(address _tradeRouter, address[] traders) → bool[]` (external)

Returns an array of booleans to indicate whether or not a position is
        liquidatable.
        Note: this is not a view function and will cost gas when executed on chain.
        Even worse, this contract would be receiving liquidation funds instead of
        the caller.
        This should only be called with callStatic.




### `receive()` (external)



Need this in order for the `tradeRouter.liquidate()` not to revert when called from `isLiquidatable`.




