// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TransferHelper.sol";

interface s_ETH_STAKE_interface {
    function getReward() external;
}

contract Lava is Ownable{

    constructor () public {
        
    }
    receive() external payable {}

     ///the owner can withdraw any erc20 token from himself
    function withdraw(address token, address to, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    ///withdraw eth from this contract
    // return HT
    function withdrawETH(address to, uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(to, amount);
    }    

    //single eth stake reward lava contract address 
    address public LAVA = 0x56f95662e71f30b333b456439248c6de589082a4;
    address public s_ETH_STAKE = 0x41e49031680cf425322232deebe9a7732963438a;//
    address public router = 0xe38623b265b5acc9f35e696381769e556ed932f9;//swap router
    address public l_LAVA_USDT_LP_STAKE = 0x9d90609b6c90cc378fe15bfa9edf249d3f3abf6e;//pool
    address public LAVA_USDT_LP = 0x3f15f2075aa11be4757aa522d133c0dbc7e878ce;
    address public USDT = 0x0;

    function roolup_s_eth_to_lava_usdt_lp() external onlyOwner {
        //step1: getReward() from s_ETH_STAKE
        s_ETH_STAKE_interface(s_ETH_STAKE).getReward();
        //step2: read lava balance
        uint256 lavaAmount = IERC20(LAVA).balanceOf(msg.sender);

        //step3: swapExactTokensForTokens of router
        // getAmountsOut and than calcu the minimal usdt out count;
        // function getAmountsOut(uint amountIn, address[] memory path)
        // call swapExactTokensForTokens of router
        // function swapExactTokensForTokens(
            // uint amountIn,
            // uint amountOutMin,
            // address[] calldata path,
            // address to,
            // uint deadline
        amounts = router_interface(router).getAmountsOut(lavaAmount/2 , [LAVA, USDT]);
        uint256 amountOutMin = amounts[amounts.length - 1] * 99 /100;
        deadline = block.timestamp + 10000000;
        amounts = router_interface(router).swapExactTokensForTokens(lavaAmount/2, amountOutMin, [LAVA, USDT], msg.sender, deadline);

        //step4: addLiquidity() of router
        //getsmountsOut 
        // function addLiquidity(
        // address tokenA,
        // address tokenB,
        // uint amountADesired,
        // uint amountBDesired,
        // uint amountAMin,
        // uint amountBMin,
        // address to,
        // uint deadline
        uint a_lava = lavaAmount/2;
        uint a_usdt =  amounts[amounts.length -1];

        router_interface(router).addLiquidity(LAVA, USDT, a_lava, a_usdt, a_lava * 98/100, a_usdt * 98/100, msg.sender, deadline);


        //step5: deposit(uint256 _pid, uint256 _amount)  pid = 0
        //  amount = LAVA_USDT_LP.balanceOf()
        //  l_LAVA_USDT_LP_STAKE.deposit(0, amount)

    } 
    function removeStake(){

    }
    function removeLiquidity() {

    }
}