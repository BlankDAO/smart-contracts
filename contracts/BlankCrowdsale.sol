pragma solidity ^0.4.24;

import "./openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./openzeppelin/contracts/math/SafeMath.sol";
import "./openzeppelin/contracts/ownership/Ownable.sol";
import "./BlankToken.sol";


/**
 * @title BlankCrowdsale contract.
 */
contract BlankCrowdsale is Ownable {
    using SafeMath for uint256;

    uint256 public lastMintId;
    uint256 public halfLifeCounter;

    uint256 public genesisPoint;
    uint256 public tokensPerMint;
    uint256 public price; // 10**18 blank tokens are worth how many stable token

    BlankToken internal blankToken;
    ERC20 internal stableToken;
    address public daoFinanceAddr;

    uint256 constant public MINTING_FREQUENCY = 600; // seconds
    uint256 constant public HALFLIFE_DIVISOR = 2;
    uint256 constant public HALFLIFE = 210000 * 600; // seconds
    uint256 constant public BLANK_TOKEN_PARTS = 10**18;

    string private constant UNTIMELY_REQUEST = "UNTIMELY_REQUEST";
    string private constant INITIALIZED_BEFORE = "INITIALIZED_BEFORE";
    string private constant INSUFFICIENT_ALLOWANCE = "INSUFFICIENT_ALLOWANCE";
    string private constant TOKENS_NOT_AVAILABLE = "TOKENS_NOT_AVAILABLE";

    event Minted(uint256 indexed mintId, uint256 amount);
    event Buy(uint256 amount, uint256 price, address buyer);

    constructor(address blankTokenaddr, address stableTokenAddr)
        public
    {
        blankToken = BlankToken(blankTokenaddr);
        stableToken = ERC20(stableTokenAddr);
        tokensPerMint = 50 * 10**18;
        genesisPoint = block.timestamp;
        price = 10 * 10**16; // 10 cent
    }

    /**
     * @notice Set DAO finance's address.
     * @param _daoFinanceAddr The DAO finance's address.
     */
    function setDaoFinance(address _daoFinanceAddr)
        external
        onlyOwner
    {
        require(daoFinanceAddr == address(0), INITIALIZED_BEFORE);

        daoFinanceAddr = _daoFinanceAddr;
    }

    /**
     * @notice Set stableToken address.
     * @param stableTokenAddr Satable token's smart contract address.
     */
    function setStableToken(address stableTokenAddr)
        external
        onlyOwner
    {
        stableToken = ERC20(stableTokenAddr);
    }

    /**
     * @notice mint BlankToken.
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
        if (lastMintId > 1 && blankToken.balanceOf(address(this)) == 0) {
            price = price.mul(101).div(100);
        }
        emit Minted(lastMintId, tokensPerMint);
        blankToken.mint(address(this), tokensPerMint);
    }

    /**
     * @notice Buy blank token.
     */
    function buy()
        external
    {
        uint256 balance = blankToken.balanceOf(address(this));
        require(0 < balance, TOKENS_NOT_AVAILABLE);

        uint256 allowance = stableToken.allowance(msg.sender, address(this));
        uint256 blankAmount = allowance.mul(BLANK_TOKEN_PARTS).div(price);
        require(0 < blankAmount, INSUFFICIENT_ALLOWANCE);
        if (balance < blankAmount) {
            blankAmount = balance;
        }
        uint256 stableAmount = blankAmount.mul(price).div(BLANK_TOKEN_PARTS);
        if (stableToken.transferFrom(msg.sender, daoFinanceAddr, stableAmount)) {
            emit Buy(blankAmount, stableAmount, msg.sender);
            blankToken.transfer(msg.sender, blankAmount);
        }
    }
}
