App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    $('#loader').show();
    return App.initWeb3();
  },


  initWeb3: async function() {

    if (window.ethereum) {
        App.web3Provider = window.ethereum;
        window.web3 = new Web3(ethereum);
        try {
            // Request account access if needed
            await ethereum.enable();
        } catch (error) {
            console.log(error.message)
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        App.web3Provider = web3,currentProvider;
        window.web3 = new Web3(web3.currentProvider);
    }
    // Non-dapp browsers...
    else {
    // If no injected web3 instance is detected, fall back to Ganache
        App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        window.web3 = new Web3(App.web3Provider);
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Edfolio.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var AdoptionArtifact = data;
      App.contracts.Edfolio = TruffleContract(AdoptionArtifact);

      // Set the provider for our contract
      App.contracts.Edfolio.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return true;
    }).then(function(result) {
        return App.getHighSchool();
    });
    App.bindEvents();
    return true;
  },

  bindEvents: function(){
    $(document).on('click', '.studentNameBTN', App.showStudentInfo);
  },

  getHighSchool: function(){

    var edfolioInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(instance){
        edfolioInstance = instance;
        var highSchoolIndex = sessionStorage.getItem("HighSchoolID");

        return edfolioInstance.getHighSchoolAddressAtIndex(highSchoolIndex, {from: account});
      }).then(function(address){
        return edfolioInstance.getHighSchool(address, {from: account});
      }).then(function(result){
        console.log(result);
        var hsAddress = result[0];
        var hsName = result[2];
        var hsStudents = result[3];

        $('#title').text(hsName);
//        $('#short-bio').text(hsAddress);

        App.getStudents(hsStudents);

        return true;
      });
    });
  },

  addStudent: function(){
    var studentAddress = $('#addStudentAddress').val();
    var studentName = $('#addStudentName').val();

    console.log(web3.eth);

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.addStudent(studentAddress, {from: account});
      }).then(function(result) {
      // CHECK result FOR CORRECT EVENT FROM addStudent THEN DO THE
      // FOLLOWING TO REFRESH THE UI
        App.getHighSchool();
      }).catch(function(err){
        console.log(err.message);
      });
     });
  },

  getStudents: function(studentList){

    var edfolioInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];
      App.contracts.Edfolio.deployed()
      .then(function(instance) {
        edfolioInstance = instance;
        var studentRow = $('#studentRow');
        var studentTemplate = $('#studentTemplate');

        studentList.forEach(function(studentAddress, index){
            edfolioInstance.getStudent(studentAddress, {from: account})
            .then(function(student){
                studentTemplate.find('.studentNameBTN').text(student[0]);
                studentTemplate.find('.studentNameBTN').attr('data-id', index);
//                    studentTemplate.find('.studentNameBTN').attr('data-id')

                studentRow.append(studentTemplate.html());
            });
        });
        return true;
      });
    });
  },


  getStudentInfo: function(studentID){
    var edfolioInstance;
    var studentAddress;

    return new Promise(function(accept,reject){
       web3.eth.getAccounts(function(error, accounts) {
          if (error) {
            console.log(error);
          }

          var account = accounts[0];

          App.contracts.Edfolio.deployed()
          .then(function(instance) {
            edfolioInstance = instance;
            return edfolioInstance.getHighSchool(account, {from:account});
          }).then(function(highSchool){
            studentAddress = highSchool[3][studentID];
            return edfolioInstance.getStudent(studentAddress, {from: account});
          }).then(function(student){
            accept([student, studentAddress]);
          });
        });
    });
  },


//        if(studentName){
//
//        }
//        if(HSTranscriptKeyList.length > 0){
//            App.getStudentHSTranscript(HSTranscriptKeyList)
//            .then(function(result){
//                if(result){
//                    $('#class-table')[0].style.display='block';
//                }
//            }).catch(function(err){
//                console.log(err.message);
//            });
//        }
//        if(dateGraduatedHS){}
//
//
//        $('#loader').hide()
//        })

  showStudentInfo: function(event){
    event.preventDefault();

    var studentID = parseInt($(event.target).data('id'));

    App.getStudentInfo(studentID)
    .then(function(studentInfo){
        $('#student-Info-Name')[0].innerHTML = studentInfo[0][0];
        App.getStudentHSTranscript(studentInfo[0][3], studentInfo[1])
        .then(function(result){
            if(result){
                $('#studentInfo')[0].style.display='block';
            }
        }).catch(function(err){
            console.log(err.message);
        });
    });

    sessionStorage.setItem("studentClicked", studentID);
  },

  addClass: function(){
    var studentID = sessionStorage.getItem("studentClicked");
    var ClassName = $('#addClassName').val();
    var ClassTeacher = $('#addClassTeacher').val();
    var ClassCode = $('#addClassCode').val();
    var ClassSemester = $('#addClassSemester').val();
    var ClassGrade = $('#addClassGrade').val();


    var edfolioInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed()
      .then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.getHighSchool(account,{from: account});
      }).then(function(result){
        var hsStudents = result[3];
        var studentAddress = hsStudents[studentID];
        console.log("Student Address: " + studentAddress);
        return edfolioInstance.addHighschoolClass(studentAddress, ClassSemester, ClassName, ClassCode, ClassTeacher, {from: account});
      }).then(function(result){
        //MATCH EVENT TO ClassAdded AND DISPLAY MESSAGE
        console.log("Result: " + result);
      }).catch(function(err){
        console.log(err.message);
      });
    });
  },

  openClassToEdit: function(){
    var rowData = $(event.target).closest('tr').find('td');

    $('#editClassName').val(rowData[0].innerHTML);
    $('#editClassCode').val(rowData[1].innerHTML);
    $('#editClassSemester').val(rowData[2].innerHTML);
    $('#editClassTeacher').val(rowData[3].innerHTML);
    $('#editClassGrade').val(rowData[4].innerHTML);

    sessionStorage.setItem("prevTeacher", rowData[3].innerHTML);
    sessionStorage.setItem("prevGrade", rowData[4].innerHTML);

    $('#editClassForm')[0].style.display='block';
  },

  editClass: function(){

    var studentID = sessionStorage.getItem("studentClicked");

    var classCode = $('#editClassCode').val();
    var classTeacher = $('#editClassTeacher').val();
    var classGrade = $('#editClassGrade').val();

    var prevTeacher = sessionStorage.getItem("prevTeacher");
    var prevGrade = sessionStorage.getItem("prevGrade");


    var edfolioInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed()
      .then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.getHighSchool(account,{from: account});
      }).then(function(result){
        var hsStudents = result[3];
        var studentAddress = hsStudents[studentID];

        if(prevTeacher != classTeacher){
            App.updateHighschoolClassTeacher(studentAddress, classCode, classTeacher)
            .then(function(result){
                console.log("Inside promise return for TEACHER");
                //DO SOMETHING WITH EVENT;
            });
        }

        if(prevGrade != classGrade){
            App.updateHighschoolGrade(studentAddress, classCode, classGrade)
            .then(function(result){
                console.log("Inside promise return for GRADE");
                //DO SOMETHING WITH EVENT;
            });
        }
      });
    });
  },

  updateHighschoolGrade: function(student, classCode, grade){
    var edfolioInstance;

    return new Promise(function(accept,reject){
        web3.eth.getAccounts(function(error, accounts) {
          if (error) {
            console.log(error);
          }

          var account = accounts[0];

          App.contracts.Edfolio.deployed().then(function(instance) {
            edfolioInstance = instance;
            return edfolioInstance.updateHighschoolGrade(student, classCode, grade, {from: account});
          }).then(function(result){
            accept(result);
          }).catch(function(err){
            console.log(err.message);
          });
        });
    });
  },

  updateHighschoolClassTeacher: function(student, classCode, teacher){
    var edfolioInstance;

    return new Promise(function(accept,reject){
        web3.eth.getAccounts(function(error, accounts) {
          if (error) {
            console.log(error);
          }

          var account = accounts[0];

          App.contracts.Edfolio.deployed().then(function(instance) {
            edfolioInstance = instance;
            return edfolioInstance.updateHighschoolClassTeacher(student, classCode, teacher, {from: account});
          }).then(function(result){
            accept(result);
          }).catch(function(err){
            console.log(err.message);
          });
        });
    });
  },

  getStudentHSTranscript: function(HSTranscriptKeyList, studentAddress){
    var hsTableBody = $('#student-transcript').find('tbody');
    hsTableBody.empty();

    HSTranscriptKeyList.forEach(function(key, index){
        App.getSingleHSClass(key, studentAddress)
        .then(function(hsClass){
            var newRow = hsTableBody[0].insertRow(index);
            newRow.addEventListener('click', function(){App.openClassToEdit()});
            var classCell = newRow.insertCell(0);
            classCell.innerHTML = hsClass[1];
            var codeCell = newRow.insertCell(1);
            codeCell.innerHTML = App.hexToASCII(hsClass[2]);
            var semesterCell = newRow.insertCell(2);
            semesterCell.innerHTML = App.hexToASCII(hsClass[0]);
            var teacherCell = newRow.insertCell(3);
            teacherCell.innerHTML = hsClass[3];
            var gradeCell = newRow.insertCell(4);
            gradeCell.innerHTML = hsClass[4];
        }).catch(function(err){
            console.log(err.message);
        });
    });

    return new Promise(function(accept,reject){
        accept(true);
    });
  },

  hexToASCII: function(hexInput){
    var hexString = hexInput.toString();
    var strTemp = '';
    for (var i = 0; (i < hexString.length && hexString.substr(i, 2) !== '00'); i += 2)
        strTemp += String.fromCharCode(parseInt(hexString.substr(i, 2), 16));
    return strTemp;
  },

  getSingleHSClass: function(ClassCode, studentAddress){
    var edfolioInstance;

    return new Promise(function(accept,reject){
        web3.eth.getAccounts(function(error, accounts) {
          if (error) {
            console.log(error);
          }

          var account = accounts[0];

          App.contracts.Edfolio.deployed().then(function(instance) {
            edfolioInstance = instance;
            return edfolioInstance.getHSClass(studentAddress, ClassCode, {from: account});
          }).then(function(hsClass){
            accept(hsClass);
          }).catch(function(err){
            console.log(err.message);
          });
        });
    });
  }
};

$(function() {
  $(window).on('load',function() {
    App.init();
  });
});
