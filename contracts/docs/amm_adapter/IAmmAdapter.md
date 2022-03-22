## `IAmmAdapter`

Implementations of this interface have all the details needed to interact with a particular AMM.
This pattern allows Futureswap to be extended to use several AMMs like UniswapV2 (and forks like Trader Joe),
UniswapV3, Trident, etc while keeping the details to connect to them outside of our core system.




### `swap(address recipient, address token0, address token1, int256 token1Amount) → int256 token0Amount` (external)

Swaps `token1Amount` of `token1` for `token0`. If `token1Amount` is positive, then the `recipient`
will receive `token1`, and if negative, they receive `token0`.




### `getPrice(address token0, address token1) → int256 price` (external)

Returns the price of the specified token0 relatively to token1.







