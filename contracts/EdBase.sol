pragma solidity ^0.4.18;

import "./EdAccessControl.sol";

contract EdBase is EdAccessControl{

    event OnboardedNewStudent(address indexed studentAddress, uint indexed studentIndex);
    event OnboardedNewHS(address indexed HSAddress, uint indexed HSIndex);
    event SchoolAdded(address indexed studentAddress, string schoolName);
    event ClassAdded(address indexed studentAddress, bytes7 classCode, bytes4 semesterCode);
    event ClassTeacherUpdate(address indexed studentAddress, bytes7 classCode, string newTeacher);
    event ClassGradeUpdate(address indexed studentAddress, bytes7 classCode, uint8 grade);
    event Graduated(address indexed studentAddress);
    event NewStudentAdded(address hsAddress, uint studentID);

    /* Structs for Class */
    struct Class {
        bytes4 semesterCode;
        string name;
        bytes7 classCode;
        string teacherName;
        uint8 grade;
    }


    struct Student {
        string name; /*This needs to get changed to a valid form of identity -- change addStudent below to reflect identity change*/
        bool isStudent;
        address highschool;
        string highschoolName;
        bytes7[] HSTranscriptKey;
        mapping(bytes7 => Class) HSTranscript;
        uint40 dateGraduatedHS;
        address[] college;
        mapping(address => string) collegeNames;
        bytes7[] collegeTranscriptKey;
        mapping(bytes7 => Class) collegeTranscript;
        //Degree[] degrees;
        //Certification[] cert;
        //StandardizedTest[] standTest;
    }

    struct HighSchool {
        address hsAddress;
        bool isHighSchool;
        string hsName;
        address[] students;
    }

    struct University {
        address univAddress;
        bool isUniversity;
        string univName;
        address[] students;
    }

    mapping(address => Student) public StudentProfiles;
    address[] public studentList;

    mapping(address => HighSchool) public HighSchoolProfiles;
    address[] public highSchoolList;

    mapping(address => University) public UniversityProfiles;
    address[] public universityList;


    function onboardStudent(string memory studentName) public payable{
        require(StudentProfiles[msg.sender].isStudent == false);
        StudentProfiles[msg.sender].name = studentName;
        StudentProfiles[msg.sender].isStudent = true;
        uint studentCount = studentList.push(msg.sender);
        uint studentIndex = studentCount - 1;
        emit OnboardedNewStudent(msg.sender, studentIndex);
    }

    // Highschool functions

    function onboardHighSchool(string memory highSchoolName) public payable{
        require(HighSchoolProfiles[msg.sender].isHighSchool == false);
        HighSchoolProfiles[msg.sender].hsAddress = msg.sender;
        HighSchoolProfiles[msg.sender].hsName = highSchoolName;
        HighSchoolProfiles[msg.sender].isHighSchool = true;
        uint HSCount = highSchoolList.push(msg.sender);
        uint HSIndex = HSCount - 1;
        emit OnboardedNewHS(msg.sender, HSIndex);
    }

    function getHighSchool(address hsAddress)
        public
        view
        returns(
        address,
        bool,
        string memory,
        address[] memory
    ){
        HighSchool memory HS = HighSchoolProfiles[hsAddress];
        return (HS.hsAddress, HS.isHighSchool, HS.hsName, HS.students);
    }

    function getHighSchoolAddressAtIndex(uint index) public view returns(address){
        return highSchoolList[index];
    }
}
