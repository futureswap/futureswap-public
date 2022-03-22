## `ChainlinkOracle`






### `constructor(address _oracle, address _token0, address _token1, int256 _token0Decimals, int256 _token1Decimals)` (public)

Create an oracle with a given underlying Chainlink pricefeed and tokens. Token0 and Token1 need to match
those of the oracle to have the same price direction.




### `getPrice(address token) → int256` (external)

Returns the price of a supported token, relatively to the other token.






