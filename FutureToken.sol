pragma solidity >0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/IERC20.sol";

//WETH 0x0a180A76e4466bF68A7F86fB029BEd3cCcFaAac5
//DAI 0x3ac1c6ff50007ee705f36e40F7Dc6f393b1bc5e7

contract Utils {
    function sqrt(uint y) public pure returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}

}

contract Pool is ERC20 {
    Utils utils = new Utils();
    
    IERC20 token1;
    IERC20 token2;
    
    uint token1Liquidity = 0;
    uint token2Liquidity = 0;
    uint totalLiquidity = token1Liquidity * token2Liquidity;
  
    constructor (IERC20 _token1, IERC20 _token2) ERC20("POOL", "LP") {
        token1 = _token1;
        token2 = _token2;

    }
    
    function addLiquidity(uint token1Amt, uint token2Amt) public returns (bool) {
        require(token1.balanceOf(msg.sender) >= token1Amt && token2.balanceOf(msg.sender) >= token2Amt, "you don't own enough tokens");
        
        uint retTokens = 0;
        uint addedLiquidity = token1Amt * token2Amt;
        if(token1Liquidity == 0 && token2Liquidity == 0) {
            retTokens = utils.sqrt(token1Amt * token2Amt);
        } else {
            token1Amt * token2Amt;
            retTokens = totalSupply() * (addedLiquidity /  totalLiquidity);
        }
       
        //make sure to approve first
        require(token1.transferFrom(msg.sender, address(this), token1Amt), "transfer didn't work");
        require(token2.transferFrom(msg.sender, address(this), token2Amt), "transfer didn't work");
        
        token1Liquidity += token1Amt;
        token2Liquidity += token2Amt;
        
        _mint(msg.sender, retTokens);
        return true;
    }
    
    function redeem(uint _amt) public returns (bool) {
        require(balanceOf(msg.sender) >= _amt, "You don't have enough LP Tokens");
        
        token1Liquidity -= _amt;
        token2Liquidity -= _amt;
        
        token1.transfer(msg.sender, token1Liquidity * _amt / totalSupply()); //this might cause a problem
        token2.transfer(msg.sender, token2Liquidity * _amt / totalSupply());
        
        _burn(msg.sender, _amt);
        return true;
    }
    
    IERC20[] tokens = [token1, token2];
    uint[] tokenLiquidities = [token1Liquidity, token2Liquidity];
    
    function swap(uint _token1Amt, uint _token2Amt) public returns (bool) {
        require(_token1Amt==0||_token2Amt==0);

        int tokenID = 1;
        uint k = totalLiquidity;
        uint amt1 = _token2Amt;
        uint amt2 = k / tokenLiquidities[uint(tokenID)];
        
        if(_token1Amt==0) {
            amt1 = _token1Amt;
            tokenID = -1;
        }
        
        tokenLiquidities[uint(tokenID)] += amt1;
        tokenLiquidities[uint(-1*tokenID)] += amt2;
        
        tokens[uint(tokenID)].transferFrom(msg.sender, address(this), amt1);
        tokens[uint(-1*tokenID)].transfer(msg.sender, amt2);
        
        return true;
    }
}
