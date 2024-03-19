import { createWalletClient, http, parseUnits } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { foundry } from "viem/chains";
import accounts from "./accounts/balances.json" assert { type: "json" };
import addresses from "./artifacts/addresses.json" assert { type: "json" };
import "dotenv/config";

const walletKey = process.env.ADMIN_PRIVATE_KEY;
const chainId = process.env.CHAIN_ID;
const rpcUrl = process.env.RPC_URI;

const account = privateKeyToAccount(walletKey);
const chain = {
  ...foundry,
  id: Number(chainId),
  rpcUrls: {
    default: {
      http: [rpcUrl],
      webSocket: [rpcUrl],
    },
  },
};
const transport = http(rpcUrl);

console.log("account", account.address);
console.log("chainId", chainId);
console.log("rpcUrl", rpcUrl);
console.log("addresses", addresses);

const abi = [
  {
    name: "mint",
    type: "function",
    inputs: [
      { name: "destination", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [],
  },
];

const walletClient = createWalletClient({
  account,
  chain,
  transport,
});

async function fundAccount(address, eth = 0, tokens = 0) {
  const ethBalance = parseUnits(String(eth), 18);
  const tokenBalance = parseUnits(String(tokens), 18);

  if (ethBalance) {
    console.log("Funding", address, "with", ethBalance.toString(), "ETH");
    await fetch(rpcUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "anvil_setBalance",
        params: [address, `0x${ethBalance.toString(16)}`],
      }),
    });
    console.log("Funded", address, "with", ethBalance.toString(), "ETH");
  }

  if (tokenBalance) {
    console.log("Funding", address, "with", tokenBalance.toString(), "BASE");
    await walletClient.writeContract({
      abi,
      address: addresses.baseToken,
      functionName: "mint",
      args: [address, tokenBalance],
    });
  }
}

// Fund the admin account
// await fundAccount(account.address, 1_000);

// Fund the accounts in the balances.json file
for (const [address, { eth, tokens }] of Object.entries(accounts)) {
  await fundAccount(address, eth, tokens);
}

process.exit(0);
