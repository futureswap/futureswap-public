## `TokenVault`

TokenVault is the only contract in the Futureswap system that stores ERC20 tokens, including both collateral
and liquidity. Each exchange has its own instance of TokenVault, which provides isolation of the funds between
different exchanges and adds an additional layer of protection in case one exchange gets compromised.
Users are not meant to interact with this contract directly. For each exchange, only the TokenRouter and the
corresponding implementation of IAmm (for example, SpotMarketAmm) are authorized to withdraw funds. If new versions
of these contracts become available, then they can be approved and the old ones disapproved.



We decided to make TokenVault non-upgradable. The implementation is very simple and in case of an emergency
recovery of funds, the VotingExecutor (which should be the owner of TokenVault) can approve arbitrary addresses
to withdraw funds.

### `onlyApprovedAddress()`

Requires caller to be an approved address.




### `constructor(address _admin)` (public)





### `setAddressApproval(address userAddress, bool approved)` (external)

Changes the approval status of an address. If an address is approved, it's allowed to move funds from
the vault. Can only be called by the VotingExecutor.





### `transfer(address recipient, address token, uint256 amount)` (external)

Transfers the given amount of token from the vault to a given address.
This can only be called by an approved address.





### `setIsFrozen(bool _isFrozen)` (external)

For security we allow admin/voting to freeze/unfreeze the vault this allows an admin
to freeze funds, but not move them.




### `VaultApprovalChanged(address userAddress, bool previousApproval, bool currentApproval)`

Emitted when approvals for `userAddress` changes. Reports the value before the change in
`previousApproval` and the value after the change in `currentApproval`.



### `VaultTokensTransferred(address recipient, address token, uint256 amount)`

Emitted when `amount` tokens are transfered from the TokenVault to the `recipient`.



### `VaultFreezeStateChanged(bool previousFreezeState, bool freezeState)`

Emitted when the vault is frozen/unfrozen.





