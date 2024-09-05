// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

contract ExchangeError {
    error InvalidReserve();
    error InvaildTokenSold();
    error InsufficientOutputAmount();
    error InvaildEthSold();
    error TransferError();
    error ZeroAddress();
    error InvaildAmount();
}
