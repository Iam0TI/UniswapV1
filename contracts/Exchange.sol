// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ExchangeError} from "./ExchangeError.sol";

contract Exchange is ExchangeError, ERC20("Liquidity Token", "LPT") {
    IERC20 public tokenaddress;

    constructor(address _tokenaddress) {
        if (_tokenaddress == address(0)) revert ZeroAddress();
        tokenaddress = IERC20(_tokenaddress);
    }

    function addLiquidity(uint256 _amount) external payable returns (uint256) {
        if (_amount <= 0) revert InvaildAmount();
        if (getTokenReserve() <= 0) {
            tokenaddress.transferFrom(msg.sender, address(this), _amount);

            uint256 liquidity = address(this).balance;
            _mint(msg.sender, liquidity);

            return liquidity;
        } else {
            uint256 tokenReserve = getTokenReserve();
            uint256 ethReserve = (address(this).balance - msg.value);

            uint256 tokenAmount = (tokenReserve * msg.value) / ethReserve;

            if (tokenAmount < _amount) revert InvaildAmount();

            tokenaddress.transferFrom(msg.sender, address(this), tokenAmount);

            uint256 liquidity = (totalSupply() * msg.value) / ethReserve;

            _mint(msg.sender, liquidity);
            return liquidity;
        }
    }

    function removeLiqudity(uint256 _amount) external returns (uint256, uint256) {
        if (_amount <= 0) revert InvaildAmount();
        uint256 tokenAmount = (getTokenReserve() * _amount) / totalSupply();
        uint256 ethAmount = (address(this).balance * _amount) / totalSupply();

        _burn(msg.sender, _amount);

        tokenaddress.transfer(msg.sender, tokenAmount);

        (bool success,) = msg.sender.call{value: ethAmount}("");
        if (!success) revert TransferError();

        return (tokenAmount, ethAmount);
    }

    function ethToTokenSwap(uint256 _minTokens) external payable {
        uint256 tokenReserve = getTokenReserve();
        uint256 tokenBought = getAmount(msg.value, address(this).balance - msg.value, tokenReserve);

        if (tokenBought < _minTokens) revert InsufficientOutputAmount();

        tokenaddress.transfer(msg.sender, tokenBought);
    }

    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) external {
        uint256 tokenReserve = getTokenReserve();
        uint256 ethBought = getAmount(_tokensSold, tokenReserve, address(this).balance);

        if (ethBought < _minEth) revert InsufficientOutputAmount();

        tokenaddress.transferFrom(msg.sender, address(this), _tokensSold);

        (bool success,) = msg.sender.call{value: ethBought}("");
        if (!success) revert TransferError();
    }

    function getEthAmount(uint256 _tokenSold) private view returns (uint256) {
        if (_tokenSold < 0) {
            revert InvaildTokenSold();
        }
        uint256 tokenReserve = getTokenReserve();

        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    /*amountMinted =  totalAmount  ∗  ethReserve/ethDeposited​ */
    function getTokenAmount(uint256 _ethSold) private view returns (uint256) {
        if (_ethSold < 0) revert InvaildEthSold();

        uint256 tokenReserve = getTokenReserve();

        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    /* helper function to get swap  amount
        the price function  is
        (x +dx)(y-dy) =xy =k
            dy = ydx/x+dx
            */
    function getAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve)
        private
        pure
        returns (uint256)
    {
        if (inputReserve <= 0 || outputReserve <= 0) revert InvalidReserve();

        uint256 inputAmountWIthFee = inputAmount * 98;

        uint256 numerator = inputAmountWIthFee * outputReserve;

        uint256 denominator = (inputReserve * 100) + inputAmountWIthFee;

        return numerator / denominator;
    }

    // helper function to get the token balance of this contract
    function getTokenReserve() private view returns (uint256) {
        return tokenaddress.balanceOf(address(this));
    }
}
