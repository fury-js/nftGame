//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

import "hardhat/console.sol";

// inherits from openzeppelin
contract EpicNftGame is ERC721 {
    // We'll hold our character's attributes in a struct. Feel free to add
    // whatever you'd like as an attribute! (ex. defense, crit chance, etc).

    // The tokenId is the NFTs unique identifier, it's just a number that goes
    // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;

    }

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.

    mapping(address => uint256) public nftHolders;

    // events
    event CharacterMinted(address sender, uint tokenId, uint characterIndes);
    event AttackComplete(uint newBossHp, uint newPlayerHp);


        // A lil array to help us hold the default data for our characters.
        // This will be helpful when we mint new characters and need to know
        // things like their HP, AD, etc.
    


    CharacterAttributes[] public defaultCharacters;

    
        // Data passed in to the contract when it's first created initializing the characters.
        // We're going to actually pass these values in from from run.js.
    
    constructor(
        // We'll hold our character's attributes in a struct. Feel free to add
        // whatever you'd like as an attribute! (ex. defense, crit chance, etc).
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDmg
    ) ERC721("NFT Combat", "Combat") {
        // Initialize the boss. Save it to our global "bigBoss" state variable
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDmg
        });

        console.log("Done initializing boss:", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
        // Loop through all the characters, and save their values in our contract so
        // we can use them later when we mint our NFTs.
        for(uint i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
            }));

            CharacterAttributes memory character = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", character.name, character.hp, character.imageURI);
        }
        // I increment tokenIds here so that my first NFT has an ID of 1.
        // More on this in the lesson!
        tokenIds.increment();
    }

    // Users would be able to hit this function and get their NFT based on the
    // characterId they send in!
    function mintCharacter(uint _characterIndex) external {
        // Get Current tokenId
        uint newItemId = tokenIds.current();

        // assign token id to caller
        _safeMint(msg.sender, newItemId);

        // map token id to character attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ token Id %s and character Index %s", newItemId, _characterIndex);

        nftHolders[msg.sender] = newItemId;

        tokenIds.increment();

        emit CharacterMinted(msg.sender, newItemId, _characterIndex);
    }


    

    function tokenURI(uint _tokenId) public view override returns(string memory) {
        CharacterAttributes memory char = nftHolderAttributes[_tokenId];
        
        string memory strHp = Strings.toString(char.hp);
        string memory strMaxHp = Strings.toString(char.maxHp);
        string memory strAttackDamage = Strings.toString(char.attackDamage);


        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name: "',
                            char.name,
                        ' --NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an Nft for playing games in Death Trap!", "image": "ipfs://',
                        char.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,'} ]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {

        uint nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        // make sure player has enough hp
        require(player.hp > 0, "player has no health points to attack");
        // make sure boss has enough hp
        require(bigBoss.hp > 0, "Boss has no health points to attack");

        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

        if(bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        if(player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        emit AttackComplete(bigBoss.hp, player.hp);

        console.log("Player attacked the boss and Player now has %s hp",  player.hp);
        console.log("Boss Attacked player New Boss Hp is %s",  bigBoss.hp);
    }

    function checkIfUserHasNft() public view returns(CharacterAttributes memory) {
        uint userNftTokenId = nftHolders[msg.sender];

        if(userNftTokenId > 0){
            CharacterAttributes memory userNftAttributes = nftHolderAttributes[userNftTokenId];
            return userNftAttributes; 
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }


    function getAllCharacters() public view returns(CharacterAttributes[] memory) {
        return defaultCharacters;
    }


    function getBigBoss() public view returns(BigBoss memory) {
        return bigBoss;
    }
}
