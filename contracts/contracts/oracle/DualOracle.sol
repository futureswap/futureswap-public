//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "../exchange41/interfaces/IOracle.sol";
import "../lib/Utils.sol";

/// @title An adapter for combining two oracles of token0:<commonToken> and token1:<commonToken> to token0:token1.
contract DualOracle is IOracle {
    /// @notice Fixed point base to calculate prices and maintain precision.
    /// Defined as int256 as Chainlink returns prices in int256.
    int256 private constant PRICE_FIXED_POINT_BASED = 10**18;

    /// @notice The oracle for token0:<commonToken>.
    IOracle public immutable oracle0;

    /// @notice The oracle for token1:<commonToken>.
    IOracle public immutable oracle1;

    /// @inheritdoc IOracle
    address public immutable override token0;

    /// @inheritdoc IOracle
    address public immutable override token1;

    /// @notice Create an oracle with two given oracles that share the same underlying token1.
    constructor(address _oracle0, address _oracle1) {
        // Use temp variables to hold oracles here as we cannot use the instance variable oracles yet as they're
        // immutable.
        IOracle oracle0_ = IOracle(FsUtils.nonNull(_oracle0));
        IOracle oracle1_ = IOracle(FsUtils.nonNull(_oracle1));
        // Make sure oracle0 and oracle1 are of the form token0:<commonToken> and token1:<commonToken> respectively.
        require(
            oracle0_.token0() != oracle1_.token0() && oracle0_.token1() == oracle1_.token1(),
            "Wrong tokens"
        );
        oracle0 = oracle0_;
        oracle1 = oracle1_;
        token0 = oracle0_.token0();
        token1 = oracle1_.token0();
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view override returns (int256) {
        require(token == token0 || token == token1, "Wrong tokens");

        int256 price0 = oracle0.getPrice(token0);
        int256 price1 = oracle1.getPrice(token1);
        // Avoid division by zero. Price shouldn't be zero but we'll leave it up to the caller to reject 0 if needed.
        if (price0 == 0 || price1 == 0) {
            return 0;
        }

        if (token == token0) {
            return (price0 * PRICE_FIXED_POINT_BASED) / price1;
        } else {
            return (price1 * PRICE_FIXED_POINT_BASED) / price0;
        }
    }
}
