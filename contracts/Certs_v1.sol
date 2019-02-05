pragma solidity ^0.4.24;

contract Certifications {
	//more modular wya to add cert types in the future???? 
	
	struct Certs {
		uint16 type; // Score, Work experience, Degree, Certification
		bytes title;
		uint256 issuedOn;
		uint256 expiresOn;
		bool revokable;
		address issuedBy;
		address recipient;
		address[] canView;
	}

	struct Recipient{
		bool isRecipient
		bool inPool
		Certs[] achievements;
	}

	mapping(address => Recipient) recipients;
}