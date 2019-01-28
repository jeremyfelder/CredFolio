pragma solidity ^0.4.24;

import "./EdBase.sol";

contract EdUniversity is EdBase{

    modifier isStudentsCollege(address student) {
        address[] memory colleges = getCollegeAddresses(student);
        bool isStudents = false;
        for (uint i = 0; i < colleges.length; i++){
            if(colleges[i] == msg.sender)
                isStudents = true;
        }
        require(isStudents);
        _;
    }

    function addCollegeClass(
        address studentToUpdate,
        bytes4 semesterCode,
        string memory className,
        bytes7 classCode,
        string memory teacherName
    )
        isStudentsCollege(studentToUpdate)
        public {
        Class memory classToAdd = Class(semesterCode, className, classCode, teacherName, 0);
        StudentProfiles[studentToUpdate].collegeTranscript[classCode] = classToAdd;
        StudentProfiles[studentToUpdate].collegeTranscriptKey.push(classCode);
        emit ClassAdded(studentToUpdate, classCode, semesterCode);
    }

    function updateCollegeClassTeacher(
        address studentToUpdate,
        bytes7 classCode,
        string memory newTeacher
    )
        isStudentsCollege(studentToUpdate)
        public {
        StudentProfiles[studentToUpdate].collegeTranscript[classCode].teacherName = newTeacher;
        emit ClassTeacherUpdate(studentToUpdate, classCode, newTeacher);
    }

    // Highschool attests to a final grade in a particular class for a student
    function updateCollegeGrade(
        address studentToUpdate,
        bytes7 classCode,
        uint8 grade
    )
        isStudentsCollege(studentToUpdate)
        public{
        StudentProfiles[studentToUpdate].collegeTranscript[classCode].grade = grade;
        emit ClassGradeUpdate(studentToUpdate, classCode, grade);
    }

    function getCollegeAddresses(address student) public view returns (address[] memory){
        return StudentProfiles[student].college;
    }

//    modifier isStudentOrStudentsCollege(){
//        _;
//    }

//
//    function getCollegeName(address student, address college) public view returns (string){
//        return StudentProfiles[student].collegeNames[college];
//    }
//
//    function getCollegeTranscriptKeyList(address student) public view isStudent returns (bytes7[]){
//        return StudentProfiles[student].collegeTranscriptKey;
//
//    }
//
//    function getCollegeClassCount(address student) public view isStudent returns (uint){
//        return StudentProfiles[student].collegeTranscriptKey.length;
//    }
}
