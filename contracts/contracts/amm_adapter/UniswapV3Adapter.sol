//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.7;

import "./IAmmAdapter.sol";
import "./IAmmAdapterCallback.sol";
import "../external/uniswap/ISwapPool.sol";
import "../external/uniswap/IPoolSwapCallback.sol";
import "../lib/FsMath.sol";
import "../lib/Utils.sol";

/// @title The AMM adapter for UniswapV3 pools.
/// @dev This adapter is not meant to be used for general purposes. This remains public and has no access control in
/// case it might be shared by multiple components (e.g. multiple AMMs) in the system. It also does not have connection
/// to any contract in the Futureswap system.
contract UniswapV3Adapter is IAmmAdapter, IPoolSwapCallback {
    /// @dev Constant setting no price limit for swapping token0 for token1 on a UniswapV3 pool.
    uint160 private constant NO_LIMIT_ZERO_FOR_ONE = 4295128740;

    /// @dev Constant setting no price limit for swapping token1 for token0 on a UniswapV3 pool.
    uint160 private constant NO_LIMIT_ONE_FOR_ZERO =
        1461446703485210103287273052203988822378723970341;

    /// @notice The UniswapV3 pool this adapter is for. We make this immutable to avoid needing a setter and an owner
    /// for this contract. If the underlying Uniswap pool needs to change, then we will do a new deployment of this
    /// contract and update the IAmm contract that's using it.
    ISwapPool public immutable uniswapV3Pool;

    /// @notice The underlying AMM's token0.
    address public immutable poolToken0;
    /// @notice The underlying AMM's token1.
    address public immutable poolToken1;

    /// @notice Data to pass to UniswapV3#swap so UniswapV3 will pass it back when calling back to request payment.
    struct PaymentCallbackData {
        // The address that called swap on this adapter.
        address swapper;
    }

    constructor(address _uniswapV3Pool) {
        // We need to use a temp variable as functions cannot be invoked on immutable variable in the constructor.
        // slither-disable-next-line missing-zero-check
        ISwapPool tempUniswapV3Pool = ISwapPool(FsUtils.nonNull(_uniswapV3Pool));
        poolToken0 = tempUniswapV3Pool.token0();
        poolToken1 = tempUniswapV3Pool.token1();
        uniswapV3Pool = tempUniswapV3Pool;
    }

    /// @inheritdoc IAmmAdapter
    function swap(
        address recipient,
        address token0,
        address token1,
        int256 token1Amount
    ) external override returns (int256 token0Amount) {
        require(token1Amount != 0, "Token1 is zero");
        require(
            (token0 == poolToken0 && token1 == poolToken1) ||
                (token0 == poolToken1 && token1 == poolToken0),
            "Wrong tokens"
        );

        return doSwap(msg.sender, recipient, token0, token1Amount);
    }

    /// @inheritdoc IPoolSwapCallback
    function uniswapV3SwapCallback(
        int256 _amount0Owed,
        int256 _amount1Owed,
        bytes calldata _calldata
    ) external override {
        // Only callback from the external AMM is allowed.
        // We trust that UniV3 pools will not be calling this callback out of the trading flow but even if the unlikely
        // chance that it does, the SpotMarketAmm contract that relies on this contract already has protection against
        // making payments outside of trading flow.
        require(msg.sender == address(uniswapV3Pool), "Not the right sender");

        PaymentCallbackData memory callbackData = abi.decode(_calldata, (PaymentCallbackData));
        address swapper = FsUtils.nonNull(callbackData.swapper);
        address token0 = uniswapV3Pool.token0();
        address token1 = uniswapV3Pool.token1();

        // Forward the payment request to the current swapper.
        IAmmAdapterCallback(swapper).sendPayment(
            address(uniswapV3Pool),
            token0,
            token1,
            _amount0Owed,
            _amount1Owed
        );
    }

    /// @notice Swaps token0 for token1 if asset token1Amount is positive. Otherwise, swap token1 for token0.
    function doSwap(
        address swapper,
        address recipient,
        address token0,
        int256 token1Amount
    ) private returns (int256) {
        // The Uniswapv3 pool is directional with its own token0 and token1 so we need to match them with the given
        // token0 and token1. There are 4 cases:
        // If swapping token0 for token1 and:
        //     token0 matches Uniswap's token0, we're swapping in Uniswap's direction.
        //     Otherwise, we're swapping against Uniswap's direction.
        // If swapping token1 for token0 and:
        //     token0 matches Uniswap's token0, we're swapping against Uniswap's direction.
        //     Otherwise, we're swapping in Uniswap's direction.
        bool token0MatchesUniswapToken0 = token0 == uniswapV3Pool.token0();
        bool swappingInUniswapDirection =
            token1Amount > 0 ? token0MatchesUniswapToken0 : !token0MatchesUniswapToken0;

        // The Q64.96 sqrt price limit. If swapping zero for one, the price cannot be less than this value after swap.
        // If one for zero, the price cannot be greater than this value.
        uint160 sqrtPriceLimitX96 =
            swappingInUniswapDirection ? NO_LIMIT_ZERO_FOR_ONE : NO_LIMIT_ONE_FOR_ZERO;

        // External call to UniswapV3. This has a separate callback to ask for payments so we don't need to pay here
        // yet.
        // slither-disable-next-line uninitialized-local
        PaymentCallbackData memory callbackData;
        callbackData.swapper = swapper;
        int256 token1AmountToSwap = -token1Amount;
        (int256 amount0, int256 amount1) =
            uniswapV3Pool.swap(
                // Send the tokens to recipient directly.
                recipient,
                swappingInUniswapDirection,
                token1AmountToSwap,
                sqrtPriceLimitX96,
                // We need to pass the swapper address along the payment callback can use it.
                abi.encode(callbackData)
            );

        // The returned (amount0, amount1) are the deltas of the UniswapV3 pool so they're the reverse of what we
        // pay/receive (UniswapV3 pool's decrease = This contract's increase).
        return token0MatchesUniswapToken0 ? -amount0 : -amount1;
    }

    /// @dev Returns the marginal spot price from UniswapV3. This should never be used in the system as an oracle price
    /// as it can be manipulated by flashloans and should only be used for display purposes.
    /// @inheritdoc IAmmAdapter
    function getPrice(address token0, address token1) external view override returns (int256) {
        require(
            (token0 == poolToken0 && token1 == poolToken1) ||
                (token0 == poolToken1 && token1 == poolToken0),
            "Wrong tokens"
        );

        // We don't support sqrtPriceX96 > 10**12 (2**40) so we assume sqrtPriceX96 is actually Q40.96 here instead of
        // Q64.96 (max 2**64 or 10**19).
        (uint160 sqrtPriceX96, , , , , , ) = uniswapV3Pool.slot0();

        // This reduces sqrtPrice from Q40.96 to Q40.48. 48 precision bits should be sufficient.
        int256 sqrtPrice = int256(uint256(sqrtPriceX96)) >> 48;
        // Price is a Q80.96 number so it has 176 bits.
        int256 price = sqrtPrice * sqrtPrice;

        // Avoid division by zero.
        if (price == 0) {
            return 0;
        }

        if (token0 == uniswapV3Pool.token0()) {
            // Price * FIXED_POINT_BASED is only 176 + 60 = 236 bits max so it won't overflow.
            return (price * FsMath.FIXED_POINT_BASED) >> 96;
        } else {
            // FsMath.FIXED_POINT_BASED << 96 is (60 + 96) = 156 bits. Won't overflow.
            return (FsMath.FIXED_POINT_BASED << 96) / price;
        }
    }

    /// @inheritdoc IAmmAdapter
    function supportedTokens() external view override returns (address[] memory tokens) {
        tokens = new address[](2);
        tokens[0] = poolToken0;
        tokens[1] = poolToken1;
    }
}
