pragma solidity ^0.4.17;

contract Edfolio {

    /* This is the owner address of Edfolio*/
    address public owner;

    constructor (){
        owner = msg.sender;
    }

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

    /* Structs for Degree */
    struct Degree {
        string major;
        string minor;
        uint40 dateReceived;
    }

    /* Structs for Student */
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
        Degree[] degrees;
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

    /* Mappings for the Student, College/University, and HighSchool profiles*/
    mapping(address => Student) StudentProfiles;
    address[] studentList;

    mapping(address => HighSchool) HighSchoolProfiles;
    address[] highSchoolList;

    mapping(address => University) UniversityProfiles;
    address[] universityList;

    /* Modifiers for access rights*/


    modifier isStudent(){
        require(StudentProfiles[msg.sender].isStudent == true);
        _;
    }

    modifier isHighSchool(){
        require(HighSchoolProfiles[msg.sender].isHighSchool == true);
        _;
    }

    /* check to see if the highschool has rights to upload to this students profile*/
    modifier isStudentsHighschool(address student) {
        require(StudentProfiles[student].highschool == msg.sender);
        _;
    }

    modifier isStudentOrStudentsHS(address student){
        require((StudentProfiles[msg.sender].isStudent || (msg.sender == StudentProfiles[student].highschool)));
        _;
    }

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

    modifier isStudentOrStudentsCollege(){
        _;
    }

    // Functions
    // Student functions

    // Onboard a student to the platform
    function onboardStudent(string studentName) public{
        require(StudentProfiles[msg.sender].isStudent == false);
        StudentProfiles[msg.sender].name = studentName;
        StudentProfiles[msg.sender].isStudent = true;
        uint studentCount = studentList.push(msg.sender);
        uint studentIndex = studentCount - 1;
        emit OnboardedNewStudent(msg.sender, studentIndex);
    }

    // Student can add or update their highschool
    function addHighschool(address highschoolAddress, string HSName)
        isStudent
        isStudentOfHighSchool(highschoolAddress)
        public {
            require(HighSchoolProfiles[highschoolAddress].isHighSchool == true);
            StudentProfiles[msg.sender].highschool = highschoolAddress;
            StudentProfiles[msg.sender].highschoolName = HSName;
            emit SchoolAdded(msg.sender, HSName);
    }

    function getStudentCount() public view returns (uint) {
        return studentList.length;
    }
    function getStudentAddressAtIndex(uint index) public view returns (address){
        return studentList[index];
    }

    function getStudent(address student) isStudentOrStudentsHS(student) public view returns (string name, address highschool, string highschoolName, bytes7[] HSTranscriptKey, uint40 dateGraduatedHS, address[] college, bytes7[] collegeTranscriptKey){
        Student memory tempStudent = StudentProfiles[student];
        return (tempStudent.name,
                tempStudent.highschool,
                tempStudent.highschoolName,
                tempStudent.HSTranscriptKey,
                tempStudent.dateGraduatedHS,
                tempStudent.college,
                tempStudent.collegeTranscriptKey);
    }

    // Highschool functions

    function onboardHighSchool(string highSchoolName) public{
        require(HighSchoolProfiles[msg.sender].isHighSchool == false);
        HighSchoolProfiles[msg.sender].hsAddress = msg.sender;
        HighSchoolProfiles[msg.sender].hsName = highSchoolName;
        HighSchoolProfiles[msg.sender].isHighSchool = true;
        uint HSCount = highSchoolList.push(msg.sender);
        uint HSIndex = HSCount - 1;
        emit OnboardedNewHS(msg.sender, HSIndex);
    }

    function getHighSchoolAddressAtIndex(uint index) public view returns(address){
        return highSchoolList[index];
    }

    function getHighSchool(address hsAddress) public view returns(address, bool, string, address[]){
        HighSchool memory HS = HighSchoolProfiles[hsAddress];
        return (HS.hsAddress, HS.isHighSchool, HS.hsName, HS.students);
    }

    function addStudent(address newStudent) isHighSchool{
        require(StudentProfiles[newStudent].isStudent == true);
        uint studentCount = HighSchoolProfiles[msg.sender].students.push(newStudent);
        uint studentID = studentCount - 1;
        emit NewStudentAdded(msg.sender, studentID);
    }

    function getStudents() view isHighSchool returns (address[]){
        return HighSchoolProfiles[msg.sender].students;
    }

    // Highschool adds a class for a student
    function addHighschoolClass(address studentToUpdate, bytes4 semesterCode, string className, bytes7 classCode, string teacherName) isStudentsHighschool(studentToUpdate) public{
        Class memory classToAdd = Class(semesterCode, className, classCode, teacherName, 0);
        StudentProfiles[studentToUpdate].HSTranscript[classCode] = classToAdd;
        StudentProfiles[studentToUpdate].HSTranscriptKey.push(classCode);
        emit ClassAdded(studentToUpdate, classCode, semesterCode);
    }

    /*function getAllHSClasses(address student) view isStudent returns (Class[]) {
        Class[] allClasses;
        uint transcriptKeyLength = getHSClassCount(student);
        bytes7[] transcriptKeys = getHSTranscriptKeyList(student);


        for (uint i = 0; i < transcriptKeyLength; i++){
            Class memory class;
            (bytes4 semesterCode, string name, bytes7 classC, string teacherName, uint8 grade) = getHSClass(student, transcriptKeys[i]);
            allClasses.push(Class(semesterCode, name, classC, teacherName, grade));
        }
    }*/

    function getHSTranscriptKeyList(address student) view isStudent public returns (bytes7[]) {
        return StudentProfiles[student].HSTranscriptKey;

    }

    function getHSClassCount(address student) view isStudent public returns (uint) {
        return StudentProfiles[student].HSTranscriptKey.length;
    }

    function getHSClass(address student, bytes7 classCode) view isStudentOrStudentsHS(student) public returns (bytes4 semesterCode, string name, bytes7 classC, string teacherName, uint8 grade){
        return (StudentProfiles[student].HSTranscript[classCode].semesterCode,
                StudentProfiles[student].HSTranscript[classCode].name,
                StudentProfiles[student].HSTranscript[classCode].classCode,
                StudentProfiles[student].HSTranscript[classCode].teacherName,
                StudentProfiles[student].HSTranscript[classCode].grade);
    }

    function getHSName() view isStudent public returns (string) {
        return StudentProfiles[msg.sender].highschoolName;
    }

    function updateHighschoolClassTeacher(address studentToUpdate, bytes7 classCode, string newTeacher) isStudentsHighschool(studentToUpdate) public{
        StudentProfiles[studentToUpdate].HSTranscript[classCode].teacherName = newTeacher;
        emit ClassTeacherUpdate(studentToUpdate, classCode, newTeacher);
    }

    // Highschool attests to a final grade in a particular class for a student
    function updateHighschoolGrade(address studentToUpdate, bytes7 classCode, uint8 grade)  isStudentsHighschool(studentToUpdate) public{
        StudentProfiles[studentToUpdate].HSTranscript[classCode].grade = grade;
        emit ClassGradeUpdate(studentToUpdate, classCode, grade);
    }

    function addDateGraduatedHighSchool(address studentToUpdate, uint40 dateGraduated) isStudentsHighschool(studentToUpdate) public{
        StudentProfiles[studentToUpdate].dateGraduatedHS = dateGraduated;
        emit Graduated(studentToUpdate);
    }


    //function addCollege
    function addCollege(address college, string collegeName) isStudent public{
        StudentProfiles[msg.sender].collegeNames[college] = collegeName;
        StudentProfiles[msg.sender].college.push(college);
        emit SchoolAdded(msg.sender, collegeName);
    }

    function getCollegeListLength(address student) public view returns (uint){
        return StudentProfiles[student].college.length;
    }

    function getCollegeAddresses(address student) public view returns (address[]){
        return StudentProfiles[student].college;
    }

    function getCollegeName(address student, address college) public view returns (string){
        return StudentProfiles[student].collegeNames[college];
    }

    function addCollegeClass(address studentToUpdate, bytes4 semesterCode, string className, bytes7 classCode, string teacherName) isStudentsCollege(studentToUpdate) public{
        Class memory classToAdd = Class(semesterCode, className, classCode, teacherName, 0);
        StudentProfiles[studentToUpdate].collegeTranscript[classCode] = classToAdd;
        StudentProfiles[studentToUpdate].collegeTranscriptKey.push(classCode);
        emit ClassAdded(studentToUpdate, classCode, semesterCode);
    }

    function getCollegeTranscriptKeyList(address student) public view isStudent returns (bytes7[]){
        return StudentProfiles[student].collegeTranscriptKey;

    }

    function getCollegeClassCount(address student) public view isStudent returns (uint){
        return StudentProfiles[student].collegeTranscriptKey.length;
    }

    function getCollegeClass(address student, bytes7 classCode) public view isStudent returns (bytes4 semesterCode, string name, bytes7 classC, string teacherName, uint8 grade){
        return (StudentProfiles[student].collegeTranscript[classCode].semesterCode,
                StudentProfiles[student].collegeTranscript[classCode].name,
                StudentProfiles[student].collegeTranscript[classCode].classCode,
                StudentProfiles[student].collegeTranscript[classCode].teacherName,
                StudentProfiles[student].collegeTranscript[classCode].grade);
    }

    function updateCollegeClassTeacher(address studentToUpdate, bytes7 classCode, string newTeacher) isStudentsCollege(studentToUpdate) public{
        StudentProfiles[studentToUpdate].collegeTranscript[classCode].teacherName = newTeacher;
        emit ClassTeacherUpdate(studentToUpdate, classCode, newTeacher);
    }

    // Highschool attests to a final grade in a particular class for a student
    function updateCollegeGrade(address studentToUpdate, bytes7 classCode, uint8 grade)  isStudentsCollege(studentToUpdate) public{
        StudentProfiles[studentToUpdate].collegeTranscript[classCode].grade = grade;
        emit ClassGradeUpdate(studentToUpdate, classCode, grade);
    }
}
