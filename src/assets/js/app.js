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
        var studentID = sessionStorage.getItem("studentID");
        return App.getStudentInfo(studentID);
    });
    App.bindEvents();
    return true;
  },

  bindEvents: function() {
    $(document).on('click', '.btn-submitHighSchool', App.addHighSchool);
  },

  getStudentInfo: function(studentID){
    var edfolioInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.getStudentAddressAtIndex(studentID, {from: account});
      }).then(function(studentAddress) {
        return edfolioInstance.getStudent(studentAddress, {from: account});
      }).then(function(result){
        var studentName = result[0];
        var highschoolAddress = result[1];
        var highschoolName = result[2];
        var HSTranscriptKeyList = result[3];
        var dateGraduatedHS = result[4];
        var collegeAddressList = result[5];
        var collegeTranscriptKeyList = result[6];
        if(studentName){
            $('#title').text(result[0]);
        }
        if(highschoolName){
            $('#schools-name').text(result[2]);
            var classTable = $('#class-table');
            classTable[0].style.display = 'block';
        }
        if(HSTranscriptKeyList.length > 0){
            App.getStudentHSTranscript(HSTranscriptKeyList)
            .then(function(result){
                if(result){
                    $('#class-table')[0].style.display='block';
                }
            }).catch(function(err){
                console.log(err.message);
            });
        }
        if(dateGraduatedHS){}


        $('#loader').hide()
        })
     })
  },

  getStudentHSTranscript: function(HSTranscriptKeyList){
    var hsTable = $('#hs-transcript')[0];

    HSTranscriptKeyList.forEach(function(key, index){
        App.getSingleHSClass(key)
        .then(function(hsClass){
            var newRow = hsTable.insertRow(index+1);
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

  getSingleHSClass: function(ClassCode){
    var edfolioInstance;

    return new Promise(function(accept,reject){
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }

            var account = accounts[0];

            App.contracts.Edfolio.deployed().then(function(instance) {
              edfolioInstance = instance;
              return edfolioInstance.getHSClass(account, ClassCode);
            }).then(function(hsClass){
                accept(hsClass);
            }).catch(function(err){
              console.log(err.message);
            });
        });
    });
  },

  addHighSchool: function(){

    var highschoolAddress = $('#addHighSchoolAddress').val();
    var highschoolName = $('#addHighSchoolName').val();

    console.log(web3.eth);

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.addHighschool(highschoolAddress, highschoolName, {from: account});
      }).then(function(result) {
        $('#schools-name').text(result.logs[0].args.schoolName);
        var classTable = $('#class-table');
        classTable[0].style.display = 'block';
        //CALL getStudentInfo to refresh UI
      }).catch(function(err){
        console.log(err.message);
      });
     });
  }
};

$(function() {
  $(window).on('load',function() {
    App.init();
  });
});
