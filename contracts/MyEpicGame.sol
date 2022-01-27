// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
/* NFT Contract to inherit from */
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
/* helper functions from OpenZeppelin */
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/* helper fucntion to encode in Base64 */
import "./libraries/Base64.sol";

import "hardhat/console.sol";

/* our contract inherits from ERC721, which is the standard NFT contract! */
contract myEpicGame is ERC721 {
  /* we'll hold our character's attribute in the struct below.
  Whatever you'd like as an attribute! */
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;
    uint health;
    uint maxHealth;
    uint attackDamage;
  }

  /* struct for the Boss of the game */
  struct BigBoss {
    string name;
    string imageURI;
    uint health;
    uint maxHealth;
    uint attackDamage;
  }

  BigBoss public bigBoss;
  /* the tokenId is the NFTs unique identifier, it's just a number that goes
  0,1,2,3 etc. */
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  /* An array to help us hold the default data of our characters.
  this will be helpful to know the attributes of new characters are minted */
  CharacterAttributes[] defaultCharacters;

  /* we create a mapping from the nft's tokenId => that NFTs attributes */
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
  /* we create a mapping from an address => the NFTs tokenId
  This gives us an easy way to store the owner of the NFT and reference it later */
  mapping(address => uint256) public nftHolders;
  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(uint newBossHealth, uint newPlayerHealth);

  constructor(
    /* data passed in the contract when it is first created,
    initializing the characters. We're going to pass in these values in from run.js */
    string[] memory characterName,
    string[] memory characterImageURI,
    uint[] memory characterHealth,
    uint[] memory characterAttackDamage,
    string memory bossName,
    string memory bossImageURI,
    uint bossHealth,
    uint bossAttackDamage
    )
    /* add identifier symbols for our NFT eg. Ethereum is ETH */
      ERC721("DrugLords", "DRLD")
    {
      /* initialize the boss, save it to the 'bigBoss' state viariable */
      console.log("Initializing the Boss, please wait...");

      bigBoss  = BigBoss(
        {
          name: bossName,
          imageURI: bossImageURI,
          health: bossHealth,
          maxHealth: bossHealth,
          attackDamage: bossAttackDamage
        }
        );
      console.log("-------------------------------------------------------");
      console.log("Done initializing the Boss %s w/ Health %s, img %s", bigBoss.name, bigBoss.health, bigBoss.imageURI);
      console.log("-------------------------------------------------------");
      /* Loop through all the characters and save their values in our contract */
      /* so we can use the later when we mint our nfts */
      for (uint i = 0; i < characterName.length; i += 1) {
        defaultCharacters.push(CharacterAttributes({
          characterIndex: i,
          name: characterName[i],
          imageURI: characterImageURI[i],
          health: characterHealth[i],
          maxHealth: characterHealth[i],
          attackDamage: characterAttackDamage[i]
          }));

          CharacterAttributes memory c = defaultCharacters[i];

          console.log("----------------------------------------------------------------------");
          console.log("Done initializing %s w/ Health %s, img %s", c.name, c.health, c.imageURI);
          console.log("These hands ought to be picking gold from the street, not cutting fucking onions!");
          console.log("----------------------------------------------------------------------");
      }
      /* increment _tokenIds here so that our first NFT has an ID of 1*/
      _tokenIds.increment();
  }
  /* Users will be able to hit this function and get their NFT based on the
  caracter they send in! */
  /* First, you'll see that we pass in _characterIndex. Why?
  Well, because players need to be able to tell us which character they want!
  For example, if I do mintCharacterNFT(0) then the character w/ the stats of defaultCharacters[0] is minted! */
  function mintCharacterNFT(uint _characterIndex) external {
    /* get current tokenId(starts at 1 since we incremented in the constructor) */
    /* newItemId is the id of the NFT itself.  */
    uint256 newItemId = _tokenIds.current();
    /* the magical function that assigns the tokenId to the user's wallet address */
    _safeMint(msg.sender, newItemId);
    /* we map the tokenId => their character attributes */
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      health: defaultCharacters[_characterIndex].health,
      maxHealth: defaultCharacters[_characterIndex].maxHealth,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
      });
      console.log("---------------------------------------------");
      console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
      console.log("---------------------------------------------");

      /* keepan easy way to see who owns that NFT */
      nftHolders[msg.sender] = newItemId;

      /* Increment the tokenId for the next person that uses it */
      _tokenIds.increment();
      emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHealth = Strings.toString(charAttributes.health);
  string memory strMaxHealth = Strings.toString(charAttributes.maxHealth);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

  string memory json = Base64.encode(
    abi.encodePacked(
      '{"name": "',
      charAttributes.name,
      ' -- NFT #: ',
      Strings.toString(_tokenId),
      '", "description": "This is an NFT that lets people play in the game Scarface Metaverse!", "image": "ipfs://',
      charAttributes.imageURI,
      '", "attributes": [ { "trait_type": "Health Points", "value": ',strHealth,', "max_value":',strMaxHealth,'}, { "trait_type": "Attack Damage", "value": ',
      strAttackDamage,'} ]}'
    )
  );


  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );

  return output;
}


function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
   //get the tokenId of the user's character nftTokenIdOfPlayer
   uint256 userNftTokenId = nftHolders[msg.sender];
   // If the user has a tokenId in the map, return their character
   if (userNftTokenId > 0) {
     return nftHolderAttributes[userNftTokenId];
   }
   //Why do we do userNftTokenId > 0? Well, basically there's no way to check if a key in a map exists. We set up our map like this: mapping(address => uint256) public nftHolders. No matter what key we look for, there will be a default value of 0.
   //This is a problem for user's with NFT tokenId of 0. That's why earlier, I did _tokenIds.increment() in the constructor!
   //That way, no one is allowed to have tokenId 0. This is one of those cases where we need to be smart in how we set up our code because of some of the quirks of Solidity :).
   // else, return an empty character
   else {
     CharacterAttributes memory emptyStruct;
     return emptyStruct;
   }
}


function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
  return defaultCharacters;
}

function getBigBoss() public view returns (BigBoss memory) {
  return bigBoss;
}


  /* Function that attacks the boss */
  function attackBoss() public {
  // Get the state of the player's NFT.
  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
  console.log("\n%s about to attack. Health: %s, Attack Damage: %s", player.name, player.health, player.attackDamage);
  console.log("Boss Under attack by %s!!! Boss Health: %s, Boss Attack Damage:", bigBoss.name, player.name, bigBoss.health );
  console.log("---------------------------------------------");
  // Make sure the player has more than 0 health.
  require (
    player.health > 0,
    "Error: Health too low to attack the Boss..."
    );
  // Make sure the boss has more than 0 health.
  require (
    bigBoss.health > 0,
    "Error: Boss must have health to attack..."
    );
  // Allow player to attack boss.
  if (bigBoss.health < player.attackDamage) {
    bigBoss.health = 0;
  } else {
    bigBoss.health = bigBoss.health - player.attackDamage;
  }
  // Allow boss to attack player.
  if (player.health < bigBoss.attackDamage) {
    player.health = 0;
  } else {
    player.health = player.health - bigBoss.attackDamage;
  }

  console.log("%s attacked %s. new Boss Health: %s", player.name, bigBoss.name, bigBoss.health);
  console.log("%s attacked %s. new player Health: %s\n", bigBoss.name, player.name, player.health);
  emit AttackComplete(bigBoss.health, player.health);
  }
}
