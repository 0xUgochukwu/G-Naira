// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const name = "G-NAIRA";
  const symbol = "gNGN";
  const decimals = 18;
  const initial_supply = 1000000000;
  const governor = "0x521f4570d4339f9652dd74A44883e1115c6F116F";
  const gNGN = await gNGN.deploy(name, symbol, decimals, initial_supply, governor);

  await gNGN.deployed();

  console.log(
    "G-NAIRA deployed to:",
    gNGN.address,
    "Governor:",  
    governor
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
