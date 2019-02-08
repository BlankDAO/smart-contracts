pragma solidity ^0.4.24;


/**
 * @title Finance interface.
 */
contract Finance {
    function deposit(address _token, uint256 _amount, string _reference) external payable;
}
