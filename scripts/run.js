const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('myEpicGame');
  const gameContract = await gameContractFactory.deploy(
    // data passed into the contract when it is first created. see reference in contracts/MyEpicGame.sol
    ["Frank Lopez", "Omar Suarez", "Tony Montana", "Manolo 'Manny' Ribera", "The Skull"], //names
    ['QmRTRqAhxQAh7czot6CHH36NPwQXK73mbextwBCYDzzrmA',
    'QmVCzzAysbka6QuTYTU595k1JXsMo3D5WzGsV9oBKqf9LQ',
    'QmP2VvRuFPsbgZ3J33aiFYnBtzMwMgGW78ymNZ28t746CR',
    'QmXmQr3y5wmdEgUMPhbhTR9CJz3CwQJkNJsB32vHShhbcC',
    'QmarbAcrpKVgcP6kq51CfC7YtoZb5Au64UP5av8XUA1whw' ], //Images
    [100, 80, 200, 150, 180],// health values
    [25, 20, 100, 45, 50],// attackDamage Values
    "Alejandro Sosa", //bossName
    'https://i.imgur.com/hixecBx.jpg', //bossImageURI
    1000, //bossHealth
    50, // bossAttackDamage
  );



  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  // minting character at index 2 of our array
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log("Minted NFT #1");

  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();
  console.log("Minted NFT #2");

  // txn = await gameContract.mintCharacterNFT(2);
  // await txn.wait();
  // console.log("Minted NFT #3");

  txn = await gameContract.mintCharacterNFT(3);
  await txn.wait();
  console.log("Minted NFT #4");



  console.log("Done deploying and minting!");


  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  console.log("Minted NFT #3");

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // get the value of the NFT's URI
  // it's basically saying, "go get me the data inside the NFT with tokenId 1",
  // which would be the first NFT minted


  // let returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch(error){
    console.log(error);
    process.exit(1);
  }
};

runMain();
