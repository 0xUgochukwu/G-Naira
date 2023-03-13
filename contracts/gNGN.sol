// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


// Standard ERC20 token Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract gNGN is IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Authorized Signers
    address private _governor;
    mapping(address => bool) private _signers;
    uint8 private _signerCount;

    // Blacklist
    mapping(address => bool) private _blacklist;
    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 initialSupply, address governor) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = initialSupply * 10 ** uint256(decimals);

        // Create a GOVERNOR and make him a signer 
        _governor = governor;
        _signers[_governor] = true;
        _signerCount = 1;

        // Assign the Governor the total Supply
        _balances[_governor] = _totalSupply;
        emit Transfer(address(0), _governor, _totalSupply);
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Make sure they are not sending to Zero Address as this would imply burning of tokens
        require(recipient != address(0), "gNGN: transfer to the zero address");

        // Make sure neither the sender nor reciever is blacklisted
        require(!_blacklist[msg.sender], "gNGN: sender is blacklisted");
        require(!_blacklist[recipient], "gNGN: recipient is blacklisted");

        // Mae sure the sender has sufficient tokens to make the transaction
        require(_balances[msg.sender] >= amount, "gNGN: insufficient balance");

        // Make transaction
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

      
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "gNGN: transfer to the zero address");
      
        require(!_blacklist[sender], "gNGN: sender is blacklisted");
        require(!_blacklist[recipient], "gNGN: recipient is blacklisted");
      
        require(_balances[sender] >= amount, "gNGN: insufficient balance");

        // Make sure spender is allowed by sender address to spend 
        require(_allowances[sender][msg.sender] >= amount, "gNGN: insufficient allowance");

      
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);

      
        return true;
    }
    
   
    function mint(address account, uint256 amount) public returns (bool) {
        // Only the GOVERNOR or authorized signers can mint new tokens
        require(_signers[msg.sender], "gNGN: caller is not authorized to mint tokens");
        require(account != address(0), "gNGN: mint to the zero address");

      
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        // Only the GOVERNOR or authorized signers can burn tokens
        require(_signers[msg.sender], "gNGN: caller is not authorized to burn tokens");
        require(_balances[msg.sender] >= amount, "gNGN: insufficient balance to burn");
      
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function blacklist(address account) public returns (bool) {
        // Only the GOVERNOR or authorized signers can blacklist addresses
        require(_signers[msg.sender], "gNGN: caller is not authorized to blacklist accounts");
        require(!_blacklist[account], "gNGN: account is already blacklisted");
        _blacklist[account] = true;
        return true;
    }

    function unblacklist(address account) public returns (bool) {
        // Only the GOVERNOR or authorized signers can remove blacklisted addresses
        require(_signers[msg.sender], "gNGN: caller is not authorized to unblacklist accounts");
        require(_blacklist[account], "gNGN: account is not blacklisted");
        _blacklist[account] = false;
        return true;
    }

    function addSigner(address account) public returns (bool) {
        require(_signers[msg.sender], "gNGN: caller is not authorized to add signers");
        require(!_signers[account], "gNGN: account is already a signer");
        _signers[account] = true;
        _signerCount++;
        return true;
    }

    function removeSigner(address account) public returns (bool) {
        require(_signers[msg.sender], "gNGN: caller is not authorized to remove signers");
        require(_signers[account], "gNGN: account is not a signer");
        require(_signerCount > 1, "gNGN: cannot remove last signer");
        _signers[account] = false;
        _signerCount--;
        return true;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers[account];
    }

}
