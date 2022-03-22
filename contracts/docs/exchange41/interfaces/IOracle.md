## `IOracle`

This interface allows fetching prices for two tokens.




### `token0() → address` (external)

Address of the first token this oracle adapter supports.



### `token1() → address` (external)

Address of the second token this oracle adapter supports.



### `getPrice(address _token) → int256` (external)

Returns the price of a supported token, relatively to the other token.






