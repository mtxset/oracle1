pragma solidity ^0.4.8;
contract GCU {

    struct Balances {
       mapping (address => uint256) byAddress;
       uint index;
       address[] keys;
    }

    address private feeAccount;
    uint256 private maxTransferFee;
    uint256 private transferFeePercentage;
    address private owner;

    Balances private balances;

    modifier onlyowner {
        if (msg.sender != owner){
            throw;
        }
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value, uint256 fee);
    event IncreaseSupply(address target, uint256 amount);
    event MaxTransferFee(uint256 newMaxTransferFee);
    event TransferFeePercentage(uint256 newTransferFee);
    event FeeAccount(address accountAddress);
    event Owner(address newOwner);

    function GCU() {
       owner = msg.sender;
    }

    function setOwner(address newOwner) onlyowner {
        owner = newOwner;
        Owner(newOwner);
    }

    function getOwner() returns (address) {
        return owner;
    }

    function setMaxTransferFee(uint256 newMaxTransferFee) onlyowner {
        maxTransferFee = newMaxTransferFee;
        MaxTransferFee(newMaxTransferFee);
    }

    function getMaxTransferFee() returns (uint256) {
        return maxTransferFee;
    }

    function setFeeAccount(address accountAddress) onlyowner {
        feeAccount = accountAddress;
        FeeAccount(accountAddress);
    }

    function getFeeAccount() returns (address) {
        return feeAccount;
    }

    function setTransferFeePercentage(uint256 newTransferFeePercentage) onlyowner {
        transferFeePercentage = newTransferFeePercentage;
        TransferFeePercentage(newTransferFeePercentage);
    }

    function getTransferFeePercentage() returns (uint256) {
        return transferFeePercentage;
    }

    function getName() constant returns(bytes16) {
        return "GCU";
    }

    function getBalance(address balanceAddress) returns (uint256) {
        return balances.byAddress[balanceAddress];
    }

    function increaseSupply(address target, uint256 amount) onlyowner {
        if (msg.sender != target) {
            throw;
        }
    	balances.byAddress[target] += amount;
        if(!hasKey(target)){
            balances.keys.push(target);
        }
    	IncreaseSupply(target, amount);
    }

    function sendFunds(address from, address to, uint256 value) {

        if (msg.sender != from) {
            throw;
        }

        uint256 fee = (value * transferFeePercentage) / 10000;

        if (fee < 1) {
            fee = 1;
        }

        if (maxTransferFee > 0 && fee > maxTransferFee) {
            fee = maxTransferFee;
        }

        if (value <= 0) {
            throw;
        }

        if (balances.byAddress[from] < value + fee) {
        	throw;
        }

        balances.byAddress[from] -= value;
        balances.byAddress[from] -= fee;
        balances.byAddress[to] += value;
        balances.byAddress[feeAccount] += fee;

        if(!hasKey(from)){
            balances.keys.push(from);
        }
        if(!hasKey(to)){
            balances.keys.push(to);
        }

        Transfer(from, to, value, fee);
    }

    function () {
        throw;
    }

    function destroy() onlyowner {
        selfdestruct(owner);
    }
    function hasNextKey() onlyowner returns (bool) {
        return balances.index < balances.keys.length;
    }

    function setBalancePointer(uint256 value) onlyowner {
        balances.index = value;
    }

    function nextKey() onlyowner returns (address) {
        if(!hasNextKey()){
            throw;
        }
        return balances.keys[balances.index];
    }

    function hasKey(address key) private returns (bool){
        for(uint256 i=0;i<balances.keys.length;i++){
            address value = balances.keys[i];
            if(value == key){
                return true;
            }
        }
        return false;
    }
}
