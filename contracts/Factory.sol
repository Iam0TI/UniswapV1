// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

import {Exchange} from "./Exchange.sol";

contract Factory {
    error ExchangeExist();

    mapping(address => address) public tokenToExachange;

    function createExchange(address _tokenAddress) external returns (address) {
        if (tokenToExachange[_tokenAddress] != address(0)) revert ExchangeExist();

        Exchange exchange = new Exchange(_tokenAddress);

        tokenToExachange[_tokenAddress] = address(exchange);
        return address(exchange);
    }

    function getExchangeByToken(address _tokenaddress) external view returns (address) {
        return tokenToExachange[_tokenaddress];
    }
}
