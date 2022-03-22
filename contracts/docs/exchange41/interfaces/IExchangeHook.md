## `IExchangeHook`

IExchangeHook allows to plug a custom handler in the ExchangeLedger.changePosition() execution flow,
for example, to grant incentives. This pattern allows us to keep the ExchangeLedger simple, and extend its
functionality with a plugin model.




### `onChangePosition(struct IExchangeLedger.ChangePositionData cpd)` (external)

`onChangePosition` is called by the ExchangeLedger when there's a position change.






