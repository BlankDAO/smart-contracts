pragma solidity ^0.4.24;

import "./openzeppelin/contracts/math/SafeMath.sol";
import "./openzeppelin/contracts/ownership/Ownable.sol";
import "./BlankToken.sol";


/**
 * @title Minter contract.
 */
contract Minter is Ownable {
    using SafeMath for uint256;

    uint256 public lastMintId;
    uint256 public halfLifeCounter;
    uint256 public genesisPoint;
    uint256 public tokensPerMint;

    BlankToken internal blankToken;
    address public daoFinance;

    uint256 constant public MINTING_FREQUENCY = 600; // seconds
    uint256 constant public HALFLIFE_DIVISOR = 2;
    uint256 constant public HALFLIFE = 210000 * 600; // seconds

    string private constant UNTIMELY_REQUEST = "UNTIMELY_REQUEST";

    event Minted(uint256 indexed mintId, uint256 amount);

    constructor(address blankTokenaddr)
        public
    {
        blankToken = BlankToken(blankTokenaddr);
        tokensPerMint = 50 * 10**18;
        genesisPoint = block.timestamp;
    }


    /**
     * @notice mint Blank token.
     */
    function mint()
        external
    {
        require(lastMintId.mul(MINTING_FREQUENCY).add(genesisPoint) < block.timestamp, UNTIMELY_REQUEST);

        ++lastMintId;
        if (halfLifeCounter < block.timestamp.sub(genesisPoint).div(HALFLIFE)) {
            ++halfLifeCounter;
            tokensPerMint = tokensPerMint.div(HALFLIFE_DIVISOR);
        }
        emit Minted(lastMintId, tokensPerMint);
        require(blankToken.mint(daoFinance, tokensPerMint));
    }


	/**
     * @notice Set DAO finance address.
     * @param _daoFinance The DAO finance's address.
     */
    function setDaoFinance(address _daoFinance)
        external
        onlyOwner
    {
        daoFinance = _daoFinance;
    }
}
