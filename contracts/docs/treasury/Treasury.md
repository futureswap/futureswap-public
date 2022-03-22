## `Treasury`

`Treasury` gets a fraction of trading fees. We don't have a good use case for the funds
accumulated here yet, so in the meantime, `enact` allows arbitrary usage.
This is a proxied contract using the Initializable pattern, so no constructor should be added.




### `initialize()` (external)





### `enact(address target, bytes data)` (external)

Executes an arbitrary method in the `target` address.





### `EnactTreasury(address target, bytes data)`







