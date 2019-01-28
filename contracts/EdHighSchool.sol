pragma solidity ^0.4.18;

import "./EdStudent.sol";

contract EdHighSchool is EdStudent{

    modifier isHighSchool(){
        require(HighSchoolProfiles[msg.sender].isHighSchool == true);
        _;
    }

    modifier isStudentsHighschool(address student) {
        require(StudentProfiles[student].highschool == msg.sender);
        _;
    }

    function getStudents() isHighSchool view public returns (address[] memory){
        return HighSchoolProfiles[msg.sender].students;
    }

    function addStudent(address newStudent) public payable isHighSchool {
        require(StudentProfiles[newStudent].isStudent == true);
        uint studentCount = HighSchoolProfiles[msg.sender].students.push(newStudent);
        uint studentID = studentCount - 1;
        emit NewStudentAdded(msg.sender, studentID);
    }

    function addHighschoolClass(
        address studentToUpdate,
        bytes4 semesterCode,
        string memory className,
        bytes7 classCode,
        string memory teacherName
    )
        isStudentsHighschool(studentToUpdate)
        public
        payable
    {
        Class memory classToAdd = Class(semesterCode, className, classCode, teacherName, 0);
        StudentProfiles[studentToUpdate].HSTranscript[classCode] = classToAdd;
        StudentProfiles[studentToUpdate].HSTranscriptKey.push(classCode);
        emit ClassAdded(studentToUpdate, classCode, semesterCode);
    }

    function updateHighschoolClassTeacher(
        address studentToUpdate,
        bytes7 classCode,
        string memory newTeacher
    )
        isStudentsHighschool(studentToUpdate)
        public
        payable
    {
        StudentProfiles[studentToUpdate].HSTranscript[classCode].teacherName = newTeacher;
        emit ClassTeacherUpdate(studentToUpdate, classCode, newTeacher);
    }

    // Highschool attests to a final grade in a particular class for a student
    function updateHighschoolGrade(
        address studentToUpdate,
        bytes7 classCode,
        uint8 grade
    )
        isStudentsHighschool(studentToUpdate)
        public
        payable
    {
        StudentProfiles[studentToUpdate].HSTranscript[classCode].grade = grade;
        emit ClassGradeUpdate(studentToUpdate, classCode, grade);
    }

//    function addDateGraduatedHighSchool(
//        address studentToUpdate,
//        uint40 dateGraduated
//    )
//        isStudentsHighschool(studentToUpdate)
//        public
//    {
//        StudentProfiles[studentToUpdate].dateGraduatedHS = dateGraduated;
//        emit Graduated(studentToUpdate);
//    }
}
