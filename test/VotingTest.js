
var Test = require('../config/testConfig.js');

contract('voting', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
  });

  it('contract owner can register new user', async () => {
    
    // ARRANGE
    let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
    let newUser = config.testAddresses[0]; 

    // ACT
    await config.voting.registerUser(newUser, false, {from: caller});
    let result = await config.voting.isUserRegistered.call(newUser); 

    // ASSERT
    assert.equal(result, true, "Contract owner cannot register new user");

  });


  it('function call is made when multi-party threshold is reached', async () => {
    
    // ARRANGE
    let admin1 = accounts[1];
    let admin2 = accounts[2];
    let admin3 = accounts[3];
    
    await config.voting.registerUser(admin1, true, {from: config.owner});
    await config.voting.registerUser(admin2, true, {from: config.owner});
    await config.voting.registerUser(admin3, true, {from: config.owner});
    
    let startStatus = await config.voting.isOperational.call(); 
    let changeStatus = !startStatus;

    // ACT
    await config.voting.setOperatingStatus(changeStatus, {from: admin1});
    await config.voting.setOperatingStatus(changeStatus, {from: admin2});
    
    let newStatus = await config.voting.isOperational.call(); 

    // ASSERT
    assert.equal(changeStatus, newStatus, "Multi-party call failed");

  });

 
});
