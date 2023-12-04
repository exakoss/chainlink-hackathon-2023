// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract MyChainNFT is ERC721URIStorage, Ownable, VRFConsumerBaseV2 {
    using Strings for uint256;
    uint256 internal tokenId;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

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

    // Your subscription ID.
    uint64 s_subscriptionId;

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

    constructor(address initialOwner, uint64 subscriptionId, address coordinatorAddress, bytes32 _keyhash)
        Ownable(initialOwner)
        ERC721("MyChainNFT", "MCNFT")
        VRFConsumerBaseV2(coordinatorAddress)
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

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
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
                '"name": "My Chain NFT #', tokenIdStr, '",',
                '"description": "My chain NFT stats onchain",',
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

}