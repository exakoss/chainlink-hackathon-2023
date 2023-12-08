// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * @title Chainlink Functions example consuming SVG data
 */
contract SVGConsumer is FunctionsClient, Ownable {
  using FunctionsRequest for FunctionsRequest.Request;

  // Chainlink Functions script soruce code
  string private constant SOURCE =
    "const meleeAttack = args[0]; const meleeDefense = args[1]; const svgResponse = await Functions.makeHttpRequest({url: `https://png6-se7exr4oxa-ue.a.run.app/get-generate-png?meleeAttack=${meleeAttack}&meleeDefense=${meleeDefense}`}); if(svgResponse.error) { throw Error('SVG API Error'); } const currentSVG = svgResponse.data; if(!currentSVG) { throw Error('SVG API did not return data'); } return Functions.encodeString(currentSVG);";

  // bytes32 public donId; // DON ID for the Functions DON to which the requests are sent
  uint64 private subscriptionId; // Subscription ID for the Chainlink Functions
  uint32 gasLimit = 2000000; // Gas limit for the Chainlink Functions callbacks
  // donID - Hardcoded for Mumbai
  // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
  bytes32 public donId = 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000;
  // Mapping of request IDs to weather info
  mapping(bytes32 => SVGInfo) public requests;

  struct SVGInfo {
    string meleeAttack; // wizard melee attack
    string meleeDefense; // wizard melee defense
    string svg; // svg with the image of a wizard that is being returned
  }

  event SVGInfoRequested(bytes32 indexed requestId, string meleeAttack, string meleeDefense);
  event SVGInfoReceived(bytes32 indexed requestId, string svg);
  event RequestFailed(bytes error);

  constructor(
    address router,
    uint64 _subscriptionId
  ) FunctionsClient(router) Ownable(msg.sender) {
    subscriptionId = _subscriptionId;
  }

  /**
   * @notice Request weather info for a location
   * @param _meleeAttack wizard melee attack
   * @param _meleeDefense wizard melee defense
   */
  function requestSVGInfo(string calldata _meleeAttack, string calldata _meleeDefense) external {
    string[] memory args = new string[](2);
    args[0] = _meleeAttack;
    args[1] = _meleeDefense;
    bytes32 requestId = _sendRequest(args);

    requests[requestId] = SVGInfo({meleeAttack: _meleeAttack, meleeDefense: _meleeDefense, svg: ""});
    emit SVGInfoRequested(requestId, _meleeAttack, _meleeDefense);
  }

  /**
   * @notice Process the response from the executed Chainlink Functions script
   * @param requestId The request ID
   * @param response The response from the Chainlink Functions script
   */
  function _processResponse(bytes32 requestId, bytes memory response) private {
    string memory svg = string(response);
    // uint64 timestamp = uint64(block.timestamp);

    requests[requestId].svg = svg;
    // requests[requestId].timestamp = timestamp;
    emit SVGInfoReceived(requestId, svg);
  }

  // CHAINLINK FUNCTIONS

  /**
   * @notice Triggers an on-demand Functions request
   * @param args String arguments passed into the source code and accessible via the global variable `args`
   */
  function _sendRequest(string[] memory args) internal returns (bytes32 requestId) {
    FunctionsRequest.Request memory req;
    req.initializeRequest(FunctionsRequest.Location.Inline, FunctionsRequest.CodeLanguage.JavaScript, SOURCE);
    if (args.length > 0) {
      req.setArgs(args);
    }
    requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donId);
  }

  /**
   * @notice Fulfillment callback function
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    if (err.length > 0) {
      emit RequestFailed(err);
      return;
    }
    _processResponse(requestId, response);
  }

  // OWNER

  /**
   * @notice Set the DON ID
   * @param newDonId New DON ID
   */
  function setDonId(bytes32 newDonId) external onlyOwner {
    donId = newDonId;
  }
}