const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('myEpicGame');
  const gameContract = await gameContractFactory.deploy(
    // data passed into the contract when it is first created. see reference in contracts/MyEpicGame.sol
    ["Frank Lopez", "Omar Suarez", "Tony Montana", "Manolo 'Manny' Ribera", "The Skull"], //names
    ['https://i.imgur.com/ygIMPfo.jpg', 'https://i.imgur.com/rdEXutK.jpg', 'https://i.imgur.com/3AKVl7H.jpg', 'https://i.imgur.com/4fQba4f.jpg', 'https://i.imgur.com/KBHoCuC.jpg' ], //Images
    [100, 80, 200, 150, 180],// health values
    [25, 20, 100, 45, 50],// attackDamage Values
    "Alejandro Sosa", //bossName
    'https://i.imgur.com/hixecBx.jpg', //bossImageURI
    1000, //bossHealth
    50, // bossAttackDamage
  );



  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  
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
