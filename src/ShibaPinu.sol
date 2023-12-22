//SPDX-License-Identifier:MIT

pragma solidity ^0.8.13; 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ShibaPinu is ERC20{

error NotTheOwner(address sender); 

error AddressAlreadyExists(address _address); 

error CantMint(address sender, uint256 amount); 

error AddressNotAccepted(address _address); 

address public owner; 

address[]public addressAllowed; 

mapping(address => mapping(address => uint256))internal addressToApprovedAddressesToTokensMinted; 

mapping(address => string)internal _contracToSignatureAcceptedForMint; 

constructor(address _owner)ERC20("ShibaPinu", "SB"){
owner = _owner;
}

modifier OnlyOwner(){
if(msg.sender != owner){
revert NotTheOwner(msg.sender); 
}
_; 
}

function burn(address to, uint256 amount)public{
require(to != address(this)); 
require(amount > 0); 
_burn(to, amount);
}

function mint(address _addressAllowed,address user,uint256 amount, string memory signature) public {
require(amount > 0, "Invalid amount"); 
if((msg.sender == user || msg.sender == address(_addressAllowed))){
require(canMint(_addressAllowed,user,amount,signature) == true, "Cant mint"); 
addressToApprovedAddressesToTokensMinted[user][_addressAllowed] += amount; 
_mint(user, amount);
}else{
revert("Can't mint");
}
}

function _transfer(address to, uint256 amount) public{
require(amount > 0, "Invalid amount"); 
transfer(to, amount);
}

function transferFrom(address to, uint256 amount) public {
require(amount > 0, "Invalid amount");
transferFrom(msg.sender, to, amount);
}

function _approve(address spender, uint256 value) public {
approve(spender, value);
}

function addAddressAllowed(address newAddress)public OnlyOwner(){
for(uint256 i = 0; i < addressAllowed.length; i++){
if(newAddress == addressAllowed[i]){
revert AddressAlreadyExists(newAddress); 
}
}
addressAllowed.push(newAddress); 
}

function addAcceptedSignature(address _contract, string memory signature)public OnlyOwner(){
_contracToSignatureAcceptedForMint[_contract] = signature;
}

function canMint(address to,address user,uint256 amount, string memory signature)public returns(bool){
bool addressAccepted; 
for(uint256 i = 0; i < addressAllowed.length; i++){
if(to == addressAllowed[i]){
addressAccepted = true; 
}
}
require(keccak256(abi.encode(signature)) == keccak256(abi.encode(_contracToSignatureAcceptedForMint[to])), "Signature not accepted");
if(addressAccepted == true){
bytes memory stringEncoded = abi.encodeWithSignature(signature,user,amount + addressToApprovedAddressesToTokensMinted[user][to]);
(bool success, bytes memory result) = to.call(stringEncoded); 
require(success, "Tx failed"); 
return abi.decode(result, (bool));
}else{
revert AddressNotAccepted(to); 
}
}

function returnTokensMinted(address _contract)public view returns(uint256){
return addressToApprovedAddressesToTokensMinted[msg.sender][_contract]; 
}

function returnSignatureAllowed(address _contract)public view returns(string memory){
return _contracToSignatureAcceptedForMint[_contract]; 
}

}