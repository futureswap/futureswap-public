## `IAmmAdapterCallback`






### `sendPayment(address recipient, address token0, address token1, int256 amount0Owed, int256 amount1Owed)` (external)

Adapter callback for collecting payment. Only one of the two tokens, stable or asset, can be positive,
which indicates a payment due. Negative indicates we'll receive that token as a result of the swap.
Implementations of this method should protect against malicious calls, and ensure that payments are triggered
only by authorized contracts or as part of a valid trade flow.







