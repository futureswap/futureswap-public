## `ExchangeDeployer`

This contract is upgradable via the transparent proxy pattern.




### `constructor(address _proxyAdmin, address _treasury, address _wethToken, address _rewardsToken, address _admin)` (public)



We use immutables as these parameters will not change. Immutables are not stored in storage, but directly
embedded in the deployed code and thus save storage reads. If, somehow, these need to be updated this can still
be done through a implementation update of the ExchangeDeployer proxy.

### `initialize(address _exchangeLedgerLogic, address _stakingIncentivesLogic, address _spotMarketAmmLogic)` (external)

initialize the owner and the logic contracts




### `createExchangeWithSpotMarketAmm(address _assetToken, address _stableToken, string _liquidityTokenName, string _liquidityTokenSymbol, address _priceOracle, address _ammAdapter, struct IExchangeLedger.ExchangeConfig _exchangeConfig, struct SpotMarketAmm.AmmConfig ammConfig)` (external)

Deploys a new exchange with a spot market AMM. Can only be done by the owner.




### `setLogicContracts(address _exchangeLedgerLogic, address _stakingIncentivesLogic, address _spotMarketAmmLogic)` (public)

Set the logic contracts to a new version so newly deployed contracts use the new logic.





### `LogicContractsUpdated(address exchangeLedgerLogic, address stakingIncentivesLogic, address spotMarketAmmLogic)`

Emitted when the logic contracts are updated




### `ExchangeAdded(address exchange, address creator, struct ExchangeDeployment data)`

Emitted when an exchange contract is deployed.






