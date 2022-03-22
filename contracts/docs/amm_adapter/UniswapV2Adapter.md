## `UniswapV2Adapter`



This adapter is not meant to be used for general purposes. This remains public and has no access control in
case it might be shared by multiple components (e.g. multiple AMMs) in the system. It also does not have connection
to any contract in the Futureswap system.


### `constructor(address _uniswapV2Pool)` (public)





### `swap(address recipient, address tokenA, address tokenB, int256 tokenBAmount) → int256 tokenAAmount` (external)

Swaps `token1Amount` of `token1` for `token0`. If `token1Amount` is positive, then the `recipient`
will receive `token1`, and if negative, they receive `token0`.




### `getPrice(address token0, address token1) → int256` (external)

Returns the price of the specified token0 relatively to token1.


Returns the marginal spot price from UniswapV2. This should never be used in the system as an oracle price
as it can be manipulated by flashloans and should only be used for display purposes.





