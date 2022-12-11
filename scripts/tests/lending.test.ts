require("dotenv").config();

const {
  getDefaultProvider,
  Contract,
  constants: { AddressZero },
  Wallet,
} = require("ethers");

const {
  utils: { deployContract },
} = require("@axelar-network/axelar-local-dev");

const { sleep } = require("../../utils");

const SourceLender = require("../../artifacts/contracts/SourceLender.sol/SourceLender.json");
const RemoteLendingManager = require("../../artifacts/contracts/RemoteLendingManager.sol/RemoteLendingManager.json");

const Gateway = require("../../artifacts/@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol/IAxelarGateway.json");
const IERC20 = require("../../artifacts/@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol/IERC20.json");

const TOKEN = "uusdc";

async function deploy(chain: any, wallet: any) {
  if (chain.name === "Avalanche") {
    console.log(`Deploying SourceLender on ${chain.name}.`);
    // address _gateway,
    // address _receiver,
    // string memory _thisChain,
    // string memory _lendingTokenSymbol
    const contract = await deployContract(wallet, SourceLender, [
      chain.gateway,
      chain.gasReceiver,
      chain.name,
      TOKEN,
    ]);
    chain.lender = contract.address;
    console.log(`Deployed SourceLender for ${chain.name} at ${chain.lender}`);
  } else if (chain.name === "Moonbeam") {
    console.log(`Deploying RemoteLendingManager on ${chain.name}.`);
    const contract = await deployContract(wallet, RemoteLendingManager, [
      chain.gateway,
      TOKEN,
    ]);
    chain.lender = contract.address;
    console.log(
      `Deployed RemoteLendingManager for ${chain.name} at ${chain.lender}`
    );
  }
}

async function main() {
  const chains = require("../../local.json");
  const private_key = process.env.EVM_PRIVATE_KEY;
  const wallet = new Wallet(private_key);

  const promises = [];
  for (const chain of chains) {
    const rpc = chain.rpc;
    const provider = getDefaultProvider(rpc);
    promises.push(deploy(chain, wallet.connect(provider)));
  }

  await Promise.all(promises);
}

if (require.main === module) {
  main();
}

export {};
