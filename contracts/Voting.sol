pragma solidity ^0.4.24;

contract Voting {

  /********************************************************************************************/
  /*                                       DATA VARIABLES                                     */
  /********************************************************************************************/


  struct UserProfile {
    bool isRegistered;
    bool isAdmin;
  }

  address private contractOwner;                  // Account used to deploy contract
  mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles
  bool public isOperational = true;
  uint constant M = 2;
  address[] multiCalls = new address[](0);



  /********************************************************************************************/
  /*                                       EVENT DEFINITIONS                                  */
  /********************************************************************************************/

  // No events

  /**
  * @dev Constructor
  *      The deploying account becomes contractOwner
  */
  constructor
                              (
                              ) 
                              public 
  {
    contractOwner = msg.sender;
  }

  /********************************************************************************************/
  /*                                       FUNCTION MODIFIERS                                 */
  /********************************************************************************************/

  // Modifiers help avoid duplication of code. They are typically used to validate something
  // before a function is allowed to be executed.

  /**
  * @dev Modifier that requires the "ContractOwner" account to be the function caller
  */
  modifier requireContractOwner()
  {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    _;
  }

  modifier requireOperational() 
  {
    require(isOperational, "Contract is not Operational");
    _;
  }

  /********************************************************************************************/
  /*                                       UTILITY FUNCTIONS                                  */
  /********************************************************************************************/

  /**
  * @dev Check if a user is registered
  *
  * @return A bool that indicates if the user is registered
  */   
  function isUserRegistered 
  (
    address account
  )
    external
    view
    requireOperational
  returns(bool)
  {
    require(account != address(0), "'account' must be a valid address.");
    return userProfiles[account].isRegistered;
  }

  
  function setOperatingStatus
  (
    bool mode
  ) 
  public 
   {
    require(mode != isOperational, "New mode must be different from existing mode");
    require(userProfiles[msg.sender].isAdmin, "Caller is not an admin");

    bool isDuplicate = false;
    for(uint c = 0; c < multiCalls.length; c++) {
      if (multiCalls[c] == msg.sender) {
        isDuplicate = true;
        break;
      }
    }
    require(!isDuplicate, "Caller has already called this function.");

    multiCalls.push(msg.sender);
    if (multiCalls.length >= M) {
      isOperational = mode;      
      multiCalls = new address[](0);      
    }
  }

  /********************************************************************************************/
  /*                                     SMART CONTRACT FUNCTIONS                             */
  /********************************************************************************************/

  function registerUser 
  (
    address account,
    bool isAdmin
  )
    external
    requireOperational
    requireContractOwner
  {
    require(!userProfiles[account].isRegistered, "User is already registered.");

    userProfiles[account] = UserProfile(
    {
      isRegistered: true,
      isAdmin: isAdmin
    });
  }
}

