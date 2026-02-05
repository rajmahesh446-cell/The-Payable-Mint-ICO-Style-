// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ICOToken is ERC20, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Number of tokens received per 1 ETH (e.g., 1000 tokens per ETH)
    uint256 public tokensPerEth = 1000;

    event TokensPurchased(address indexed buyer, uint256 amountEth, uint256 amountTokens);

    constructor(string memory name, string memory symbol, address admin) 
        ERC20(name, symbol) 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /**
     * @dev Allows users to buy tokens by sending ETH.
     * The minting happens automatically based on the msg.value.
     */
    receive() external payable {
        buyTokens();
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");

        // Calculation: (ETH sent * rate) 
        // Note: msg.value is in wei, ERC20 decimals are usually 18.
        uint256 tokenAmount = msg.value * tokensPerEth;

        _mint(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    /**
     * @dev Admin function to change the price.
     */
    function setRate(uint256 newRate) public onlyRole(ADMIN_ROLE) {
        tokensPerEth = newRate;
    }

    /**
     * @dev Admin function to withdraw collected ETH from the contract.
     */
    function withdrawEth() public onlyRole(ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Transfer failed");
    }
}



