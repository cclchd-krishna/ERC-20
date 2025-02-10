// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract MyToken {
    //Token Properties
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    //Address of the owner
    address public owner;

     // Mappings for balances 
    mapping(address => uint256) private balances;

    //Mapping for allowances
    mapping(address => mapping(address => uint256)) private allowances;


    //Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    //only owner can call function with this modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }


    //Constructor for the initial process
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    //Returns the token balance of a given account.
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }


    // Transfers tokens from the caller to a recipient.
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address is not allowed");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }


    // Approves a spender to transfer up to a certain amount of tokens on behalf of the caller.
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Approve to the zero address is not allowed");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    // Returns the remaining number of tokens that a spender is allowed to transfer on behalf of an owner.
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowances[tokenOwner][spender];
    }


    // Transfers tokens on behalf of an owner, provided the caller has sufficient allowance.
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to the zero address is not allowed");
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Transfer amount exceeds allowance");

        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }


    //To mint new tokens (only owner can)
    function mint(uint256 amount) public onlyOwner returns (bool) {
        totalSupply += amount;
        balances[owner] += amount;
        emit Transfer(address(0), owner, amount);
        return true;
    }


    //To transfer ownership (only owner can)
    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), "New owner cannot be the zero address");

        uint256 ownerBalance = balances[owner];
        if (ownerBalance > 0) {
            balances[newOwner] += ownerBalance;
            balances[owner] = 0;
            emit Transfer(owner, newOwner, ownerBalance);
        }

        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);

        return true;
    }
}