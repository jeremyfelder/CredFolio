pragma solidity ^0.4.18;

import "./EdBase.sol";

contract EdStudent is EdBase{

    //Ensure msg.sender is a student
    modifier isStudent(){
        require(StudentProfiles[msg.sender].isStudent == true);
        _;
    }

    //Ensure msg.sender is in the highSchool's student list
    modifier isStudentOfHighSchool(address highSchool){
        address[] memory students = HighSchoolProfiles[highSchool].students;
        bool isStudentOfHS = false;

        for (uint i = 0; i < students.length; i++){
            if(students[i] == msg.sender)
                isStudentOfHS = true;
        }
        require(isStudentOfHS);
        _;
    }

    //Ensure msg.sender is a student or the high school of the student
    modifier isStudentOrStudentsHS(address student){
        require((StudentProfiles[msg.sender].isStudent || (msg.sender == StudentProfiles[student].highschool)));
        _;
    }

    // Student can add or update their highschool
    function addHighschool(address highschoolAddress, string memory HSName)
        isStudent
        isStudentOfHighSchool(highschoolAddress)
        public
        payable {
            StudentProfiles[msg.sender].highschool = highschoolAddress;
            StudentProfiles[msg.sender].highschoolName = HSName;
            emit SchoolAdded(msg.sender, HSName);
    }

    function getStudentAddressAtIndex(uint index) public view returns (address){
        return studentList[index];
    }

    function getStudent(address student)
        isStudentOrStudentsHS(student)
        public
        view
        returns (
        string memory name,
        address highschool,
        string memory highschoolName,
        bytes7[] memory HSTranscriptKey,
        uint40 dateGraduatedHS,
        address[] memory college,
        bytes7[] memory collegeTranscriptKey
    ){
        Student memory tempStudent = StudentProfiles[student];
        return (tempStudent.name,
                tempStudent.highschool,
                tempStudent.highschoolName,
                tempStudent.HSTranscriptKey,
                tempStudent.dateGraduatedHS,
                tempStudent.college,
                tempStudent.collegeTranscriptKey);
    }

    function getHSTranscriptKeyList(address student)
        isStudent
        public
        view
        returns (
        bytes7[] memory
    ){
        return StudentProfiles[student].HSTranscriptKey;
    }

    function getHSClassCount(address student)
        isStudent
        public
        view
        returns (
        uint
    ){
        return StudentProfiles[student].HSTranscriptKey.length;
    }

    function getHSClass(address student, bytes7 classCode)
        isStudentOrStudentsHS(student)
        view
        public
        returns(
        bytes4 semesterCode,
        string memory name,
        bytes7 classC,
        string memory teacherName,
        uint8 grade
    ){
        return (StudentProfiles[student].HSTranscript[classCode].semesterCode,
                StudentProfiles[student].HSTranscript[classCode].name,
                StudentProfiles[student].HSTranscript[classCode].classCode,
                StudentProfiles[student].HSTranscript[classCode].teacherName,
                StudentProfiles[student].HSTranscript[classCode].grade);
    }

    function getHSName() isStudent view public returns (string memory) {
        return StudentProfiles[msg.sender].highschoolName;
    }

    function addCollege(address college, string memory collegeName) isStudent public payable{
        StudentProfiles[msg.sender].collegeNames[college] = collegeName;
        StudentProfiles[msg.sender].college.push(college);
        emit SchoolAdded(msg.sender, collegeName);
    }

    function getCollegeClass(
        address student,
        bytes7 classCode
    )
        public
        view
        isStudent
        returns (
        bytes4 semesterCode,
        string memory name,
        bytes7 classC,
        string memory teacherName,
        uint8 grade
    ){
        return (StudentProfiles[student].collegeTranscript[classCode].semesterCode,
                StudentProfiles[student].collegeTranscript[classCode].name,
                StudentProfiles[student].collegeTranscript[classCode].classCode,
                StudentProfiles[student].collegeTranscript[classCode].teacherName,
                StudentProfiles[student].collegeTranscript[classCode].grade);
    }
}
