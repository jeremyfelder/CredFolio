App = {
  web3Provider: null,
  contracts: {},

  init: function() {
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
        App.web3Provider = web3.currentProvider;
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
    $.getJSON('EdCore.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var AdoptionArtifact = data;
      App.contracts.Edfolio = TruffleContract(AdoptionArtifact);

      // Set the provider for our contract
      App.contracts.Edfolio.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return true;
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-signupstudent', App.handleSignUp);
    $(document).on('click', '.btn-getStudentInfo', App.handleSignIn);
    $(document).on('click', '.btn-signUpHS', App.handleSignUpHS);
    $(document).on('click', '.btn-getHSInfo', App.handleSignInHS);
    $(document).on('click', '.btn-admin', App.admin);
  },

  admin: function(event){
    window.location.replace("admin.html");
  },

  handleSignUp: function(event) {
    event.preventDefault();

    var studentName = $('#signUpVal').val();
    var edfolioInstance;

    console.log(web3.eth);


    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(edfolioInstance) {

        return edfolioInstance.onboardS(studentName, {from: account});
      }).then(function(result) {
        for (var i = 0; i < result.logs.length; i++) {
          var event = result.logs[i].event;
          console.log(result);
// TODO uncomment and delete above console.log
//          if (event == "OnboardedNewStudent") {
//            sessionStorage.setItem("studentID", result.logs[i].args.studentIndex.c[0]);
//            break;
//          }
        }
//        window.location.replace('userPage.html');
        return true;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
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
        if(studentAddress == account){
            sessionStorage.setItem("studentID", studentID);
            window.location.replace("userPage.html");
        }
      }).catch(function(err){
        console.log(err.message)
      })
    })
  },

  handleSignIn: function(event){
    event.preventDefault();

    var studentID = $('#studentID').val();

    App.getStudentInfo(studentID);
  },

  handleSignUpHS: function(event){
    event.preventDefault();

    var HSName = $('#HSsignUpVal').val();
    var edfolioInstance;

    console.log(web3.eth);


    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(edfolioInstance) {

        return edfolioInstance.onboardHighSchool(HSName, {from: account});
      }).then(function(result) {
        for (var i = 0; i < result.logs.length; i++) {
          var event = result.logs[i].event;

          if (event == "OnboardedNewHS") {
            sessionStorage.setItem("HighSchoolID", result.logs[i].args.HSIndex.c[0]);
            break;
          }
        }
        window.location.replace('HSPage.html');
        return true;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  handleSignInHS: function(event){
    event.preventDefault();

    var edfolioInstance;
    var highSchoolID = $('#highSchoolID').val();

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Edfolio.deployed().then(function(instance) {
        edfolioInstance = instance;
        return edfolioInstance.getHighSchoolAddressAtIndex(highSchoolID, {from: account});
      }).then(function(HighSchoolAddress) {
        if(HighSchoolAddress == account){
            sessionStorage.setItem("HighSchoolID", studentID);
            window.location.replace("HSPage.html");
        }
      }).catch(function(err){
        console.log(err.message)
      })
    })
  }
};

$(function() {
  $(window).on('load', function() {
    App.init();
  });
});
