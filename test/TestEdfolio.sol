pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddersses.sol";
import "../contracts/Edfolio.sol";

contract TestEdfolioAsStudent {
	Edfolio edfolio = Edfolio(DeployedAddresses.Edfolio());
	TestHighSchool highschool = TestHighSchool(DeployedAddresses.TestHighSchool());


	//Testing adding a new student
	function testAddStudent(){
		uint studentIndex = edfolio.onboardStudent("Jeremy");

		address expectedStudent = this;

		address studentAddress = edfolio.getStudentAddressAtIndex(studentIndex);

		Assert.equal(expectedStudent, studentAddress, "Student should be recorded");
	}
	
	function testAddHighSchool(){
		edfolio.addHighschool(this, "MTA");

		string expectedName = "MTA";

		Assert.equal(expectedName, edfolio.getHSName(), "School should be recorded in student profile");
	}
}


