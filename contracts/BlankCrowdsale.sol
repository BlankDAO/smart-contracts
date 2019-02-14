pragma solidity ^0.4.24;

import "./openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./openzeppelin/contracts/math/SafeMath.sol";
import "./openzeppelin/contracts/ownership/Ownable.sol";
import "./BlankToken.sol";
import "./Finance.sol";


/**
 * @title BlankCrowdsale contract.
 */
contract BlankCrowdsale is Ownable {
    using SafeMath for uint256;

    uint256 public price;

    BlankToken internal blankToken;
    ERC20 internal stableToken;
    Finance internal finance;

    uint256 constant public BLANK_TOKEN_PARTS = 10**18;
    uint256 constant public MINIMUM_PRICE = 10**18;
    uint256 constant public MINIMUM_PAYMENT = 10**18;
    uint256 constant public MAXIMUM_PAYMENT = 10**22;

    string private constant INSUFFICIENT_PAYMENT = "INSUFFICIENT_PAYMENT";
    string private constant EXCEEDED_PAYMENT = "EXCEEDED_PAYMENT";
    string private constant TOKENS_NOT_AVAILABLE = "TOKENS_NOT_AVAILABLE";
    string private constant INVALID_AMOUNT = "INVALID_AMOUNT";
    string private constant REFERRER_NA = "REFERRER_N/A";

    event Buy(uint256 amount, uint256 price, address buyer, address referrer);
    event AddReferrer(address referrer);
    event RemoveReferrer(address referrer);

    mapping(address => bool) public referrers;

    constructor(address blankTokenaddr, address stableTokenAddr, address financeAddr)
        public
    {
        blankToken = BlankToken(blankTokenaddr);
        stableToken = ERC20(stableTokenAddr);
        finance = Finance(financeAddr);
        price = 10**18; // 1 dollar
    }

    /**
     * @notice Add a referrer.
     * @param referrer The referrer's address.
     */
    function addReferrer(address referrer) external onlyOwner {
        referrers[referrer] = true;
        emit AddReferrer(referrer);
    }

    /**
     * @notice Remove the referrer.
     * @param referrer The referrer's address.
     */
    function removeReferrer(address referrer) external onlyOwner {
        require(referrers[referrer], REFERRER_NA);
        referrers[referrer] = false;
        emit RemoveReferrer(referrer);
    }

    /**
     * @notice Set DAO finance.
     * @param financeAddr The DAO finance's address.
     */
    function setFinance(address financeAddr) external onlyOwner {
        finance = Finance(financeAddr);
    }

    /**
     * @notice Set stableToken address.
     * @param stableTokenAddr Satable token's smart contract address.
     */
    function setStableToken(address stableTokenAddr) external onlyOwner {
        stableToken = ERC20(stableTokenAddr);
    }

    /**
     * @notice Set stableToken address.
     * @param _price 10**18 blank tokens are worth how many stable token.
     */
    function setPrice(uint256 _price) external onlyOwner {
        require(MINIMUM_PRICE <= _price, INVALID_AMOUNT);
        price = _price;
    }

    /**
     * @notice Buy blank token.
     */
    function buy(address referrer) external {
        require(referrers[referrer], REFERRER_NA);

        uint256 balance = blankToken.balanceOf(address(this));
        require(0 < balance, TOKENS_NOT_AVAILABLE);

        uint256 allowance = stableToken.allowance(msg.sender, address(this));
        require(allowance <= MAXIMUM_PAYMENT, EXCEEDED_PAYMENT);
        require(MINIMUM_PAYMENT <= allowance, INSUFFICIENT_PAYMENT);

        uint256 blankAmount = allowance.mul(BLANK_TOKEN_PARTS).div(price);
        if (balance < blankAmount) {
            blankAmount = balance;
            allowance = balance.mul(price).div(BLANK_TOKEN_PARTS);
        }
        if (stableToken.transferFrom(msg.sender, address(this), allowance)) {
            require(stableToken.approve(address(finance), allowance));
            finance.deposit(address(stableToken), allowance, "Crowdsale Revenue");
            emit Buy(blankAmount, allowance, msg.sender, referrer);
            require(blankToken.transfer(msg.sender, blankAmount));
        }
    }
}
