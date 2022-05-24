// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract PogoToken is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit, ERC20Votes {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isBlacklisted;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    address private _pogoInvestmentFund = 0x483C60C602a6606CA0A3A14bE921Eee0175DEB6D;
    address private _donationWalletAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 20000000*10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _fundOrBurnFee = 1;
    uint256 private _previousFundOrBurnFee = _fundOrBurnFee;
 
    uint256 public _maxTxPercent = 10;
    uint256 public _maxWalletPercent = 10;
    uint256 public _maxWalletDecimal = 18;

    uint256 public _maxTxAmount = _tTotal * _maxTxPercent / 1 * 1**1;
    uint256 public _maxWalletAmount = _tTotal * _maxWalletPercent / 1 **(1 + _maxWalletDecimal);
    
    struct Fees {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tFundOrBurn;
    }

    constructor () ERC20("PogoToken", "POGO") ERC20Permit("PogoToken") {
        _rOwned[_msgSender()] = _rTotal;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_pogoInvestmentFund] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundOrBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFundOrBurn(sender, recipient, tFundOrBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        _taxFee = taxFee;
    }

    function setFundOrBurnFeePercent(uint256 fundorBurnFee) external onlyOwner {
        _fundOrBurnFee = fundorBurnFee;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {
        _maxTxPercent = maxTxPercent;
        _maxTxAmount = _tTotal.mul(_maxTxPercent).div(10**2);
    }
    
    function setMaxWalletPercent(uint256 maxWalletPercent, uint256 maxWalletDecimal) external onlyOwner {
        _maxWalletPercent = maxWalletPercent;
        _maxWalletDecimal = maxWalletDecimal;
        
        _maxWalletAmount = _tTotal.mul(_maxWalletPercent).div(10**(2 + _maxWalletDecimal));
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (Fees memory fees) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, fees.tFee, fees.tFundOrBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, fees.tTransferAmount, fees.tFee, fees.tFundOrBurn);
    }

    function _getTValues(uint256 tAmount) private view returns (Fees memory) {
        Fees memory fees;
        
        fees.tFee = calculateTaxFee(tAmount);
        fees.tFundOrBurn = calculateFundOrBurnFee(tAmount);
        fees.tTransferAmount = tAmount.sub(fees.tFee).sub(fees.tFundOrBurn);
        return (fees);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tFundOrBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rFundOrBurn = tFundOrBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rFundOrBurn);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeFundOrBurn(address sender, address recipient, uint256 tFundOrBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rFundOrBurn = tFundOrBurn.mul(currentRate);
        
        if (sender.isContract() != true && recipient.isContract() != true) {
            _tTotal = _tTotal - tFundOrBurn;
            _rTotal = _rTotal - rFundOrBurn;
        } else {
            _rOwned[_donationWalletAddress] = _rOwned[_donationWalletAddress].add(rFundOrBurn);
            if(_isExcluded[_donationWalletAddress])
                _tOwned[_donationWalletAddress] = _tOwned[_donationWalletAddress].add(tFundOrBurn);
            }
    }
    
    function TransferErcToExternalAddress(address recipient, uint256 amount) private {
        payable(recipient).transfer(amount);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }
    
    function calculateFundOrBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundOrBurnFee).div(10**2);
    }

    function removeAllFee() private {
        if(_taxFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousFundOrBurnFee = _fundOrBurnFee;

        _taxFee = 0;
        _fundOrBurnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _fundOrBurnFee = _previousFundOrBurnFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal override {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function blacklistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = true;
    }
    
    function whitelistAddress(address account) public onlyOwner {
        _isBlacklisted[account] = false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlacklisted[from] == false && _isBlacklisted[to] == false, "Blacklisted addresses can't do buy or sell");
        
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            
        if(from != owner() && to != owner() && to != address(1))
            require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds maximum wallet token amount");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        //transfer amount, it will take tax, burn fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundOrBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFundOrBurn(sender, recipient, tFundOrBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundOrBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFundOrBurn(sender, recipient, tFundOrBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundOrBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeFundOrBurn(sender, recipient, tFundOrBurn);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }
    
    function _mint(address to, uint256 amount)	
        internal	
        override(ERC20, ERC20Votes)	
    {	
        super._mint(to, amount);	
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }     
}
/// @custom:security-contact code@chigag.studio
