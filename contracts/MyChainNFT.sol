// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract MyChainNFT is ERC721URIStorage, Ownable, VRFConsumerBaseV2, FunctionsClient {
    using Strings for uint256;
    using FunctionsRequest for FunctionsRequest.Request;

    uint256 internal tokenId;
    //tokenId of a token which metadata should be fetched from the API and not from the onchain SVG
    uint256 internal fetchedTokenId = 100;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
        // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string _png,
        bytes response,
        bytes err
    );
    // Custom error type of Chainlink Functions
    error UnexpectedRequestID(bytes32 requestId);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    
    struct Levels {
        uint256 meleeAttack;
        uint256 meleeDefense;
    }

    mapping(uint256 => RequestStatus) public s_requests;
    VRFCoordinatorV2Interface COORDINATOR;

    //store Levels for each tokenId
    mapping(uint256 => Levels) public tokenIdToLevels;
    //use this mapping to remember which request ids are associated with which tokenIds
    mapping(uint256 => uint256) public requestIdToTokenId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // State variables to store the last request ID, response, and error for Chainlink Functions
    bytes32 public s_functionsLastRequestId;
    bytes public s_functionsLastResponse;
    bytes public s_functionsLastError;

    // Your VRF subscription ID.
    uint64 s_subscriptionId;

    //Link that returns a link DALEE generated PNG is hosted deterministically
    string constant lastImageLink = "https://png9-se7exr4oxa-ue.a.run.app/get-last-image-link";

    //Callback gas limit for Chainlink Functions
    uint32 functionsGasLimit = 300000;
    //SubscriptionID hardcoded for Avalanche Fuji
    uint64 functionsSubscriptionId = 1659;
    // donID - Hardcoded for Chainlink Functions on AvalancheFuji
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 functionsDonID = 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000;
    // Functions Router address - Hardcoded for Avalanche Fuji
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address functionsRouter = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;

    // State variable to store the returned information from Chainlink Functions
    string public png;

    // JavaScript source code for Chainlink Functions
    string source =
        "const meleeAttack = args[0];"
        "const meleeDefense = args[1];"
        "const pngResponse = await Functions.makeHttpRequest({"
        "url: `https://png9-se7exr4oxa-ue.a.run.app/get-generate-png?meleeAttack=${meleeAttack}&meleeDefense=${meleeDefense}`"
        "});"
        "if (pngResponse.error) {"
        "throw Error('PNG request failed');"
        "}"
        "return pngResponse";

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    // bytes32 keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;
    bytes32 keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2000000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 2;

    constructor(uint64 subscriptionId, address coordinatorAddress, bytes32 _keyhash)
        Ownable(msg.sender)
        ERC721("MyChainNFT", "MCNFT")
        VRFConsumerBaseV2(coordinatorAddress)
        FunctionsClient(functionsRouter)
    {
        //Setup VRF
        COORDINATOR = VRFCoordinatorV2Interface(coordinatorAddress);
        keyHash = _keyhash;
        s_subscriptionId = subscriptionId;
        //Mint first 10 NFTs to the owner for easier testing
        // for (uint i = 0; i < 10; i++) {
        //     mint(msg.sender);
        // }
    }

    //Metadata related
    function generateCharacter(uint256 _tokenId) public view returns(string memory) {
        Levels memory levels = getLevels(_tokenId);
        if(_tokenId == fetchedTokenId) {
            return lastImageLink;
        }
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',"Wizard",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Melee Attack: ", Strings.toString(levels.meleeAttack) ,'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Melee Defense: ", Strings.toString(levels.meleeDefense),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevels(uint256 _tokenId) public view returns (Levels memory) {
        Levels memory levels = tokenIdToLevels[_tokenId];
        return levels;
    }

    function tokenURI(uint256 _tokenId) override(ERC721URIStorage) public view returns (string memory) {
        Levels memory _levels = tokenIdToLevels[_tokenId];
        string memory tokenIdStr = Strings.toString(_tokenId);
        string memory meleeAttackStr = Strings.toString(_levels.meleeAttack);
        string memory meleeDefenseStr = Strings.toString(_levels.meleeDefense);

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "3x Battle Wizards #', tokenIdStr, '",',
                '"description": "Chainlink Hackathon 2023",',
                '"image_data": "', generateCharacter(_tokenId), '",',
                '"attributes": [',
                    '{"trait_type": "Melee Attack", "value": "', meleeAttackStr, '"},',
                    '{"trait_type": "Melee Defense", "value": "', meleeDefenseStr, '"}',
                ']',
            '}'
        );

    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
}


    //Minting
    function mint(address to) public onlyOwner {
        _safeMint(to, tokenId);
        tokenIdToLevels[tokenId] = Levels(1,1);
        _setTokenURI(tokenId, tokenURI(tokenId));
        unchecked {
            tokenId++;
        }
    }

    function mintTokenId(address to, uint256 _tokenId) public onlyOwner {
        _safeMint(to, _tokenId);
        tokenIdToLevels[_tokenId] = Levels(1,1);
        _setTokenURI(_tokenId, tokenURI(_tokenId));
    }

    //VRF Call
    function randomizeLevels(uint256 _tokenId) external returns (uint256 requestId) {
        // The caller has to own the nft before randomizing its leves 
        require(ownerOf(_tokenId) == msg.sender, "mintTokenId: You must own the NFT to randomize its levels.");
        requestId = COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        requestIdToTokenId[requestId] = _tokenId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    //VRF Callback
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        //calculate attack, defense and speed values, each random out of 20
        uint256 attack = (_randomWords[0] % 20) + 1;
        uint256 defense = (_randomWords[1] % 20) + 1;

        uint256 _tokenId = requestIdToTokenId[_requestId];
        tokenIdToLevels[_tokenId] = Levels(attack,defense);
        _setTokenURI(_tokenId, tokenURI(_tokenId));

        emit RequestFulfilled(_requestId, _randomWords);
    }

    //VRF Request Status check
    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    //Functions sendRequest
    function sendRequest(
        uint256 _tokenId
    ) external returns (bytes32 requestId) {

        string[] memory args = new string[](2);
        args[0] = tokenIdToLevels[_tokenId].meleeAttack.toString();
        args[1] = tokenIdToLevels[_tokenId].meleeDefense.toString();

        fetchedTokenId = _tokenId;

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_functionsLastRequestId = _sendRequest(
            req.encodeCBOR(),
            functionsSubscriptionId,
            functionsGasLimit,
            functionsDonID
        );

        return s_functionsLastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_functionsLastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_functionsLastResponse = response;
        png = string(response);
        s_functionsLastError = err;

        // Emit an event to log the response
        emit Response(requestId, png, s_functionsLastResponse, s_functionsLastError);
    }
}