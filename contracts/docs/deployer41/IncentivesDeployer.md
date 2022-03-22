## `IncentivesDeployer`






### `constructor(address _proxyAdmin, address _treasury)` (public)



We use immutables as these parameters will not change. Immutables are not stored in storage, but directly
embedded in the deployed code and thus save storage reads. If, somehow, these need to be updated this can still
be done through a implementation update of the IncentivesDeployer proxy.

### `initialize(address _openInterestIncentivesLogic, address _tradingFeeIncentivesLogic, address _tokenLockerLogic)` (external)



initialize the owner and the logic contracts


### `setLogicContracts(address _openInterestIncentivesLogic, address _tradingFeeIncentivesLogic, address _tokenLockerLogic)` (external)

Set the logic contracts to a new version so newly deployed contracts use the new logic.




### `deployOpenInterestIncentives(address incentivesHook, address rewardsToken) → address` (public)

Deploy a new trade balance incentives contract.




### `deployTradingFeeIncentives(address incentivesHook, address rewardsToken) → address` (public)

Deploy a new trading fee incentives contract.




### `deployIncentivesHook(address exchange, address _rewardsToken)` (external)



Deploy incentives hook with default trade and trading fee incentives contracts for given rewards token.
If we want to create more incentives contracts with other tokens (e.g. AVAX), we can call the deploy them
separately and then add them to the incentives hook.


### `IncentivesHookAdded(address incentivesHook, address creator)`

Emitted when an incentives hook contract is deployed.



### `TradingFeeIncentivesAdded(address tradingFeeIncentives, address creator)`

Emitted when a trading fee incentives contract is deployed.



### `OpenInterestIncentivesAdded(address openInterestIncentives, address creator)`

Emitted when a trading incentives contract is deployed.



### `LogicContractsUpdated(address openInterestIncentivesLogic, address tradingFeeIncentivesLogic, address tokenLockerLogic)`

Emitted when the logic contracts are updated






