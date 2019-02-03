pragma solidity ^0.4.24;

import "./openzeppelin/contracts/token/ERC20/CappedToken.sol";


/**
 * @title Share token contract.
  * @dev ERC20 token contract.
 */
contract BlankToken is CappedToken {
    string public constant name = "blankToken";
    string public constant symbol = "BDT";
    uint32 public constant decimals = 18;

   function BlankToken(uint256 _cap) public CappedToken (_cap){
   }
}
