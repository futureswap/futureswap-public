## `IncentivesHook`



This contract needs to have an owner who can add/remove incentive contracts.

### `exchangeOnly()`






### `constructor(address _exchange)` (public)





### `addOpenInterestIncentives(address openInterestIncentives)` (external)

Register the given open interest incentives contract with the hook so that it'll get called when
there's a position change in the exchange.



### `addTradingFeeIncentives(address tradingFeeIncentives)` (external)

Register the given trading fee incentives contract with the hook so that it'll get called when
there's a position change in the exchange.



### `removeOpenInterestIncentives(address openInterestIncentives)` (external)

Remove the given open interest incentives contract so that it'll no longer get called when there's a
position change in the exchange. This does not destroy the incentives contract so users will still be able
call it to claim rewards if there's any.



### `removeTradingFeeIncentives(address tradingFeeIncentives)` (external)

Remove the given trading feeincentives contract so that it'll no longer get called when there's a
position change in the exchange. This does not destroy the incentives contract so users will still be able
call it to claim rewards if there's any.



### `onChangePosition(struct IExchangeLedger.ChangePositionData cpd)` (external)

onChangePosition is called by the ExchangeLedger when there's a position change. This function will
call all registered incentives contracts to inform them of the update so they can update rewards accordingly.
This allows partial failures so if an update call to any incentives contract fails (unlikely to happen), the
rest of the incentives contracts would still get updated.


We rely on try catch to tolerate partial failures when updating individual incentives contracts.


### `OpenInterestIncentivesUpdateFailed(address trader, address openInterestIncentives, uint256 incentivesTradeSize)`

Emitted when a call to the trader incentives fails.
        Note: This event should not be fired in regular operations, however
        to ensure that the exchange would function even if the incentives are broken
        the exchange does not revert if the incentives revert.
        This event is used in monitoring to see issues with the incentives and potentially
        upgrade and fix.




### `TradingFeeIncentivesUpdateFailed(address trader, address tradingFeeIncentives, uint256 incentivesFeeSize)`

Emitted when a call to the trading fee incentives fails.
        Note: This event should not be fired in regular operations, however
        to ensure that the exchange would function even if the incentives are broken
        the exchange does not revert if the incentives revert.
        This event is used in monitoring to see issues with the incentives and potentially
        upgrade and fix.




### `TradingFeeIncentivesAdded(address tradingFeeIncentives)`





### `TradingFeeIncentivesRemoved(address tradingFeeIncentives)`





### `OpenInterestIncentivesAdded(address openInterestIncentives)`





### `OpenInterestIncentivesRemoved(address openInterestIncentives)`







