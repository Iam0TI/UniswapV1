// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Exchange {
    error InvalidReserve();
    error InvaildTokenSold();
    error InsufficientOutputAmount();
    IERC20 public tokenaddress;

    constructor(address _tokenaddress) {
        tokenaddress = IERC20(_tokenaddress);
    }

    function ethToTokenSwap(uint256 _minTokens) external payable {
        uint256 tokenReserve = getTokenReserve();
        uint256 tokenBought = getAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        if (tokenBought < _minTokens) {
            revert InsufficientOutputAmount();
        }

        tokenaddress.transfer(msg.sender, tokenBought);
    }
    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) external {
        uint256 tokenReserve = getTokenReserve();
        uint256 ethBought = getAmount(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        if (ethBought < _minEth) {
            revert InsufficientOutputAmount();
        }

        tokenaddress.transferFrom(msg.sender,address(this), _tokensSold);

        bool(success,) = msg.sender.call{value:ethBought}("");
        require(success, "something wrong");
    }
    function getEthAmount(uint256 _tokenSold) private view returns (uint256) {
        if (_tokenSold < 0) {
            revert InvaildTokenSold();
        }
        uint256 tokenReserve = getTokenReserve();

        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }
    function getTokenAmount(uint256 _ethSold) private view returns (uint256) {
        if (_ethSold < 0) {
            revert InvaildEthSold();
        }
        uint256 tokenReserve = getTokenReserve();

        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    /* helper function to get swap  amount
        the price function  is
        (x +dx)(y-dy) =xy =k
            dy = ydx/x+dx
            */
    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) private pure returns (uint256) {
        if (inputReserve <= 0 || outputReserve <= 0) {
            revert InvalidReserve();
        }
        return (outputReserve * inputAmount) / (inputReserve + inputAmount);
    }

    // helper function to get the token balance of this contract
    function getTokenReserve() private view returns (uint256) {
        return tokenaddress.balanceOf(address(this));
    }
}
