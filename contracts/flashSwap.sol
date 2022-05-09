// SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/Uniswap.sol';

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

contract flashSwap is IUniswapV2Callee {

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant UniswapV2Factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;


    function testFlashSwap(address _tokenBorrow, uint256 _amount) external {
        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(_tokenBorrow, WETH);
        require(pair != address(0), "Token pair does not exist");
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;

        bytes memory data = abi.encode(_tokenBorrow, _amount);
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }
    function uniswapV2Call(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _data) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(token0, token1);
        require(msg.sender == pair, "msg.sender is not pair contract");

        require(_sender == address(this), "this contract is not the sender");
        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        IERC20(tokenBorrow).transfer(pair, amountToRepay);
    }
  

}