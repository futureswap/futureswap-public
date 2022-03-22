## `FsMath`






### `abs(int256 value) → uint256` (internal)





### `sabs(int256 value) → int256` (internal)





### `sign(int256 value) → int256` (internal)





### `min(int256 a, int256 b) → int256` (internal)





### `max(int256 a, int256 b) → int256` (internal)





### `clip(int256 val, int256 lower, int256 upper) → int256` (internal)





### `safeCastToSigned(uint256 x) → int256` (internal)





### `safeCastToUnsigned(int256 x) → uint256` (internal)





### `encodeValue(int256 value) → string` (external)

Encode a int256 into a string hex value prepended with a magic identifier "stable0x"



### `encodeValueStatic(int256 value) → string` (internal)

Encode a int256 into a string hex value prepended with a magic identifier "stable0x"



This is a "static" version of `encodeValue`.  A contract using this method will not
     have a dependency on the library.

### `decodeValue(bytes r) → int256` (external)

Decode an encoded int256 value above.




### `decodeValueStatic(bytes r) → int256` (internal)

Decode an encoded int256 value above.


This is a "static" version of `encodeValue`.  A contract using this method will not
     have a dependency on the library.


### `read108(uint256 data) → int256` (internal)

Returns the lower 108 bits of data as a positive int256



### `readSigned108(uint256 data) → int256` (internal)

Returns the lower 108 bits sign extended as a int256



### `pack108(int256 value) → uint256` (internal)

Performs a range check and returns the lower 108 bits of the value



### `calculateLeverage(int256 assetAmount, int256 stableAmount, int256 assetPrice) → uint256` (internal)

Calculate the leverage amount given amounts of stable/asset and the asset price.



### `assetToStable(int256 assetAmount, int256 assetPrice) → int256` (internal)

Returns the worth of the given asset amount in stable token.



### `stableToAsset(int256 stableAmount, int256 assetPrice) → int256` (internal)

Returns the worth of the given stable amount in asset token.






