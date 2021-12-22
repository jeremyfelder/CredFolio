pragma solidity ^0.4.24;

contract Onboard {
	
	constructor() {
		
	}


	/*
	@param data - contains signed message from original sender
	*/
	function onboardRecipient(address _address, bytes data) public {
		if data:
			ecrecover the signer's address from message.
			require keccak of message === onboard
			add signer's address to Recipients
			// No need to check for duplicate signups. This will be dealt with on server with CredFolio account
		else:
			add signer's address to Recipients
	}

}