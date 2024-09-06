// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

contract ExchangeError {
    error InvalidReserve();
    error InvalidTokenSold();
    error InsufficientOutputAmount();
    error InvalidEthSold();
    error TransferError();
    error ZeroAddress();
    error InvalidAmount();
    error InvalidExchangeAddress();
}
