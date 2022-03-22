//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "./IAmmAdapter.sol";
import "./IAmmAdapterCallback.sol";
import "../external/uniswap/IUniswapV2Pair.sol";
import "../external/uniswap/UniswapV2Library.sol";
import "../lib/FsMath.sol";
import "../lib/Utils.sol";

/// @title The AMM adapter for UniswapV2 pools. This can also be used for UniswapV2 forks.
/// @dev This adapter is not meant to be used for general purposes. This remains public and has no access control in
/// case it might be shared by multiple components (e.g. multiple AMMs) in the system. It also does not have connection
/// to any contract in the Futureswap system.
contract UniswapV2Adapter is IAmmAdapter {
    /// @notice The UniswapV2 pool this adapter is for. We make this immutable to avoid needing a setter and an owner
    /// for this contract. If the underlying Uniswap pool needs to change, then we will do a new deployment of this
    /// contract and update the IAmm contract that's using it.
    IUniswapV2Pair public immutable uniswapV2Pool;

    /// @notice The underlying AMM's token0.
    address public immutable poolToken0;
    /// @notice The underlying AMM's token1.
    address public immutable poolToken1;

    constructor(address _uniswapV2Pool) {
        // We need to use a temp variable as functions cannot be invoked on immutable variable in the constructor.
        // slither-disable-next-line missing-zero-check
        IUniswapV2Pair tempUniswapV2Pool = IUniswapV2Pair(FsUtils.nonNull(_uniswapV2Pool));
        poolToken0 = tempUniswapV2Pool.token0();
        poolToken1 = tempUniswapV2Pool.token1();
        uniswapV2Pool = tempUniswapV2Pool;
    }

    /// @inheritdoc IAmmAdapter
    function swap(
        address recipient,
        address tokenA,
        address tokenB,
        int256 tokenBAmount
    ) external override returns (int256 tokenAAmount) {
        require(tokenBAmount != 0, "Token1 is zero");
        require(
            (tokenA == poolToken0 && tokenB == poolToken1) ||
                (tokenA == poolToken1 && tokenB == poolToken0),
            "Wrong tokens"
        );

        (uint256 reserve0, uint256 reserve1, ) = uniswapV2Pool.getReserves();
        int256 token0Amount;
        int256 token1Amount;
        // We need to map (tokenA, tokenB) and corresponding amounts to pool's (token0, token1) to avoid having to deal
        // with 4 different cases. UniswapV2 API is different from v3 and is not flexible with direction, i.e. it only
        // allows swaps from its token0 => token1.
        if (tokenA == poolToken0) {
            token1Amount = tokenBAmount;
            token0Amount = getAmountInOrOut(token1Amount, reserve0, reserve1);
            tokenAAmount = token0Amount;
        } else {
            token0Amount = tokenBAmount;
            token1Amount = getAmountInOrOut(token0Amount, reserve1, reserve0);
            tokenAAmount = token1Amount;
        }

        doSwapByPoolOrder(recipient, token0Amount, token1Amount);
    }

    /// @notice Swap using UniswapV2 pool's token0 and token1. Exactly one of the two amounts must be positive (output)
    /// and the other must be negative (input).
    function doSwapByPoolOrder(
        address recipient,
        int256 token0Amount,
        int256 token1Amount
    ) private {
        require(
            (token0Amount > 0 && token1Amount < 0) || (token1Amount > 0 && token0Amount < 0),
            "Incorrect amounts"
        );

        address token0 = uniswapV2Pool.token0();
        address token1 = uniswapV2Pool.token1();

        // Send payments upfront. UniswapV2#swap has a callback to pay later but it can't be used as it doesn't pass the
        // amount of tokens required for payment.
        int256 token0Owed = -token0Amount;
        int256 token1Owed = -token1Amount;
        IAmmAdapterCallback(msg.sender).sendPayment(
            address(uniswapV2Pool),
            token0,
            token1,
            token0Owed,
            token1Owed
        );

        // UniswapV2 swap requires passing the desired amount of pool's token0 or token1 and 0 for the other.
        if (token1Amount > 0) {
            uint256 amountOut = FsMath.safeCastToUnsigned(token1Amount);
            uniswapV2Pool.swap(0, amountOut, recipient, "");
        } else {
            uint256 amountOut = FsMath.safeCastToUnsigned(token0Amount);
            uniswapV2Pool.swap(amountOut, 0, recipient, "");
        }
    }

    /// @notice Returns the amount of token0 as required input or output given an amount of token1
    /// (positive is output, negative is input).
    function getAmountInOrOut(
        int256 amount1,
        uint256 reserve0,
        uint256 reserve1
    ) private pure returns (int256) {
        int256 amount0;
        if (amount1 > 0) {
            // token0 is input, token1 is output.
            uint256 amountOut = FsMath.safeCastToUnsigned(amount1);
            (uint256 reserveIn, uint256 reserveOut) = (reserve0, reserve1);
            uint256 amount0In = UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
            // Since token0 is input, amount1 required should be negative.
            amount0 = -FsMath.safeCastToSigned(amount0In);
        } else {
            // token1 is input, token0 is output.
            uint256 amountIn = FsMath.safeCastToUnsigned(-amount1);
            (uint256 reserveIn, uint256 reserveOut) = (reserve1, reserve0);
            uint256 amount0Out = UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
            amount0 = FsMath.safeCastToSigned(amount0Out);
        }
        return amount0;
    }

    /// @dev Returns the marginal spot price from UniswapV2. This should never be used in the system as an oracle price
    /// as it can be manipulated by flashloans and should only be used for display purposes.
    /// @inheritdoc IAmmAdapter
    function getPrice(address token0, address token1) external view override returns (int256) {
        require(
            (token0 == poolToken0 && token1 == poolToken1) ||
                (token0 == poolToken1 && token1 == poolToken0),
            "Wrong tokens"
        );

        (uint256 reserve0_, uint256 reserve1_, ) = uniswapV2Pool.getReserves();
        // Cast to int256 for calculation consistency - we use int256 everywhere.
        int256 reserve0 = FsMath.safeCastToSigned(reserve0_);
        int256 reserve1 = FsMath.safeCastToSigned(reserve1_);
        if (token0 == poolToken0) {
            return (reserve1 * FsMath.FIXED_POINT_BASED) / reserve0;
        } else {
            return (reserve0 * FsMath.FIXED_POINT_BASED) / reserve1;
        }
    }

    /// @inheritdoc IAmmAdapter
    function supportedTokens() external view override returns (address[] memory tokens) {
        tokens = new address[](2);
        tokens[0] = poolToken0;
        tokens[1] = poolToken1;
    }
}
