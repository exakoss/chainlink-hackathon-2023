// pragma solidity 0.8.19;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/utils/Base64.sol";

// contract ChainBattles is ERC721URIStorage {
//   using Strings for uint256;
//   using Counters for Counters.Counter; 
//   uint256 private _tokenIds = 0;

//   struct Levels {
//     uint64 meleeAttack;
//     uint64 meleeDefense;
//     uint64 speed;
//   }

//   mapping(uint256 => Levels) public tokenIdToLevels;

//   constructor() ERC721 ("Chain Battles", "CBTLS"){

//   }

//   function mint() public {
//     _tokenIds.increment();
//     uint256 newItemId = _tokenIds.current();
//     _safeMint(msg.sender, newItemId);
//     tokenIdToLevels[newItemId] = 0;
//     _setTokenURI(newItemId, getTokenURI(newItemId));
//   }

//   function generateCharacter(uint256 tokenId) public returns(string memory){
//     bytes memory svg = abi.encodePacked(
//         '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
//         '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
//         '<rect width="100%" height="100%" fill="black" />',
//         '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
//         '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">', "Melee Attack: ", getLevels(tokenId).meleeAttack,'</text>',
//         '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">', "Melle Defense: ", getLevels(tokenId).meleeDefense,'</text>',
//         '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ", getLevels(tokenId).Speed,'</text>',
//         '</svg>'
//     );
//     return string(
//         abi.encodePacked(
//             "data:image/svg+xml;base64,",
//             Base64.encode(svg)
//         )    
//     );
//   }

//   function getLevels(uint256 tokenId) public view returns (Levels memory) {
//     Levels levels = tokenIdToLevels[tokenId];
//     return levels.toString();
//   }

//   function getTokenURI(uint256 tokenId) public returns (string memory){
//     bytes memory dataURI = abi.encodePacked(
//         '{',
//             '"name": "Chain Battles #', tokenId.toString(), '",',
//             '"description": "Battles onchain",',
//             '"image": "', generateCharacter(tokenId), '"',
//         '}'
//     );
//     return string(
//       abi.encodePacked(
//         "data:application/json;base64,",
//         Base64.encode(dataURI)
//       )
//     );
//   }

//   function train(uint256 tokenId) public {
//     require(_exists(tokenId), "Please use an existing token");
//     require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
//     uint256 currentLevel = tokenIdToLevels[tokenId];
//     tokenIdToLevels[tokenId] = currentLevel + 1;
//     _setTokenURI(tokenId, getTokenURI(tokenId));
//   }


// }