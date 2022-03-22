//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "../exchange41/interfaces/IOracle.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../lib/FsMath.sol";
import "../lib/Utils.sol";

/// @title An oracle for interacting with a Chainlink price feed for token0:token1.
/// The direction of this oracle contract needs to match the underlying Chainlink oracle's.
contract ChainlinkOracle is IOracle {
    /// @notice Number of decimals of fixed point base to calculate prices and maintain precision.
    /// Cast to int256 for calculation convenience.
    int256 private constant PRICE_FIXED_POINT_BASED_DECIMALS = 18;

    /// @notice The Chainlink price feed used to calculate prices.
    AggregatorV3Interface public immutable oracle;

    /// @inheritdoc IOracle
    address public immutable override token0;

    /// @inheritdoc IOracle
    address public immutable override token1;

    /// @notice `priceOracle` returns prices in a fixed point format, scaled by `10 ** priceOracle.decimals()`.
    /// As `priceOracle.decimals()` is not expected to change, we cache `10 ** priceOracle.decimals()` in this field.
    int256 private immutable oracleFixedPointBase;

    /// @notice The ratio between 2 tokens based on their decimals, expressed in fixed point based (with 18 decimals
    /// precision).
    /// For example, for ETH (18 decimals) vs USD (6 decimals). ETH to USD ratio is 10^(18 - (18 - 6)) = 10^6 or in
    /// other words, 1 unit of ETH (wei) = 10^-12 unit of USD with 18 decimals of precisions.
    /// USD to ETH ratio is 10^ (18 - (6 - 18)) = 10^30. In other words, 1 usd = 10^12 wei with 18 decimals of precision
    int256 private immutable token0To1RatioFixedPointBased;
    int256 private immutable token1To0RatioFixedPointBased;

    /// @notice Create an oracle with a given underlying Chainlink pricefeed and tokens. Token0 and Token1 need to match
    /// those of the oracle to have the same price direction.
    /// @param _oracle Address of the the underlying Chainlink oracle.
    /// @param _token0 Should match the underlying oracle's token0.
    /// @param _token1 Should match the underlying oracle's token1.
    /// @param _token0Decimals Token0's decimals.
    /// @param _token1Decimals Token1's decimals.
    constructor(
        address _oracle,
        address _token0,
        address _token1,
        int256 _token0Decimals,
        int256 _token1Decimals
    ) {
        // We unfortunately can't directly validate that token0/token1 match the underlying oracle's as Chainlink
        // oracle interface does not have public token0()/token1().
        require(_token0Decimals > 0 && _token1Decimals > 0, "Invalid token decimals");
        // Use a temp variable to hold oracle here as we cannot use the instance variable oracle yet as it's immutable.
        // slither-disable-next-line missing-zero-check
        AggregatorV3Interface oracle_ = AggregatorV3Interface(FsUtils.nonNull(_oracle));
        uint8 oracleDecimals = oracle_.decimals();
        require(oracleDecimals > 0, "Invalid oracle decimals");
        oracleFixedPointBase = FsMath.safeCastToSigned(10**oracleDecimals);

        oracle = oracle_;
        // Sanity checks of the oracle.
        // slither-disable-next-line missing-zero-check
        token0 = FsUtils.nonNull(_token0);
        // slither-disable-next-line missing-zero-check
        token1 = FsUtils.nonNull(_token1);
        // Pre-compute token ratios to save gas (so we don't need to do this for every getPrice call).
        token0To1RatioFixedPointBased = getTokenRatioFixedPointBased(
            _token0Decimals,
            _token1Decimals
        );
        token1To0RatioFixedPointBased = getTokenRatioFixedPointBased(
            _token1Decimals,
            _token0Decimals
        );
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view override returns (int256) {
        require(token == token0 || token == token1, "Wrong tokens");

        int256 price = getOraclePrice();
        // Avoid division by zero. Price shouldn't be zero but we'll leave it up to the caller to reject 0 if needed.
        if (price == 0) {
            return 0;
        }

        // To compute the unit to unit price (and not token to token price), we need to take into account the difference
        // in decimals. For example, if 1 BTC (8 decimals) = 1 ETH (18 decimals). That means 1 satoshi = 10^10 wei.
        if (token == token0) {
            return (price * token0To1RatioFixedPointBased) / oracleFixedPointBase;
        } else {
            return (token1To0RatioFixedPointBased * oracleFixedPointBase) / price;
        }
    }

    /// @notice Returns oracle price from Chainlink.
    function getOraclePrice() private view returns (int256) {
        (, int256 price, , , ) = AggregatorV3Interface(oracle).latestRoundData();
        return price;
    }

    /// @notice Returns the token ratio (in fixed point based or 18 decimals of precision) based on the given decimals.
    function getTokenRatioFixedPointBased(int256 decimals0, int256 decimals1)
        private
        pure
        returns (int256)
    {
        int256 decimalsDiff = decimals0 - decimals1;
        uint256 decimalsDiffAsFixedPointBase =
            FsMath.safeCastToUnsigned(PRICE_FIXED_POINT_BASED_DECIMALS - decimalsDiff);
        return FsMath.safeCastToSigned(10**decimalsDiffAsFixedPointBase);
    }
}
