const { forkAndExport } = require("@axelar-network/axelar-local-dev");

const { Wallet } = require("ethers");

require("dotenv").config();

async function createFork(toFund: string[]) {
  async function callback(chain: any, info: any) {
    for (const address of toFund) {
      await chain.giveToken(address, "uusdc", BigInt(1e18));
    }
  }

  await forkAndExport({
    chains: ["Moonbeam", "Avalanche"],
    accountsToFund: toFund,
    callback: callback,
  });
}

if (require.main === module) {
  const deployer_key = process.env.EVM_PRIVATE_KEY;
  const deployer_address = new Wallet(deployer_key).address;
  const toFund: string[] = [deployer_address];

  createFork(toFund);
}
