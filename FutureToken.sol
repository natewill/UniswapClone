pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FutureToken is ERC20 {

    IERC20 quoteToken;
    uint expireDate;

    event Redeemed(address sender, uint amt);
    event AssetAdded(address sender, uint amt);

    constructor(address _quoteTokenAddress, uint _expireDate) ERC20("Weth Futures", "fWETH") public {
        quoteToken = IERC20(_quoteTokenAddress);
        expireDate = _expireDate;
    }

    function redeem(uint _amt) external {
        require(block.timestamp >= expireDate);
        require(balanceOf(msg.sender) >= _amt, "you don't own this many tokens");
        quoteToken.transferFrom(address(this), msg.sender, _amt);
        _burn(msg.sender, _amt);

        emit Redeemed(msg.sender, _amt);
    }

    function addAsset(uint _amt) external {
        //must approve the contract before sending
        require(block.timestamp < expireDate, "this future expired");
        require(quoteToken.balanceOf(msg.sender) >= _amt, "you don't have enough tokens");
        require(quoteToken.transferFrom(msg.sender, address(this), _amt), "transfer failed");
        _mint(msg.sender, _amt);

        emit AssetAdded(msg.sender, _amt);
    }

    //FOR DEBUG
    function makeFutureExpire() external {
        expireDate = block.timestamp;
    }
}
