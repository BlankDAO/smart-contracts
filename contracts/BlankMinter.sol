pragma solidity ^0.4.24;

import "./openzeppelin/contracts/math/SafeMath.sol";
import "./openzeppelin/contracts/ownership/Ownable.sol";
import "./BlankToken.sol";
import "./Finance.sol";


/**
 * @title Minter contract.
 */
contract BlankMinter is Ownable {
    using SafeMath for uint256;

    uint256 public genesisPoint;

    BlankToken internal blankToken;
    Finance internal finance;

    uint256 constant public MINTING_FREQUENCY = 600; // seconds
    uint256 constant public TOKENS_PER_MINT = 50 * 10**18;

    string private constant UNTIMELY_REQUEST = "UNTIMELY_REQUEST";

    event Minted(uint256 mintId, uint256 amount);

    constructor(address blankTokenAddr, address financeAddr) public {
        blankToken = BlankToken(blankTokenAddr);
        finance = Finance(financeAddr);
        genesisPoint = block.timestamp;
    }

    /**
     * @dev Allows the current owner to relinquish control of the token.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceTokenOwnership() external onlyOwner {
        blankToken.renounceOwnership();
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferTokenOwnership(address newOwner) external onlyOwner {
        blankToken.transferOwnership(newOwner);
    }

    /**
     * @notice mint Blank token.
     */
    function mint() external {
        uint256 mintId = block.timestamp.sub(genesisPoint).div(MINTING_FREQUENCY);
        uint256 intendedSupply = mintId.mul(TOKENS_PER_MINT);
        uint256 actualSupply = blankToken.totalSupply();
        require(actualSupply < intendedSupply, UNTIMELY_REQUEST);

        emit Minted(mintId, TOKENS_PER_MINT);
        uint256 mintAmount = intendedSupply.sub(actualSupply);
        require(blankToken.mint(address(this), mintAmount));
        require(blankToken.approve(address(finance), mintAmount));
        finance.deposit(address(blankToken), mintAmount, "Minted BlankDAO tokens");
    }

	/**
     * @notice Set DAO finance address.
     * @param financeAddr The DAO finance's address.
     */
    function setFinance(address financeAddr) external onlyOwner {
        finance = Finance(financeAddr);
    }
}
