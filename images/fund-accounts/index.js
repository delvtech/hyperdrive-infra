import { createWalletClient, http, parseUnits } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { foundry } from 'viem/chains';
import accounts from '/accounts/balances.json' assert { type: 'json' };
import addresses from '/artifacts/addresses.json' assert { type: 'json' };

const walletKey = process.env.ADMIN_PRIVATE_KEY;
const chainId = process.env.CHAIN_ID;
const rpcUrl = process.env.RPC_URI;

const account = privateKeyToAccount(walletKey);
const chain = {
  ...foundry,
  id: Number(chainId),
};
const transport = http(rpcUrl);

console.log('account', account);
console.log('chainId', chainId);
console.log('rpcUrl', rpcUrl);

const abi = [
  {
    name: 'mint',
    type: 'function',
    inputs: [
      { name: 'destination', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [],
  },
];

const walletClient = createWalletClient({
  account,
  chain,
  transport,
});

for (const [address, { eth, tokens }] of Object.entries(accounts)) {
  const ethBalance = parseUnits(String(eth), 18);
  const tokenBalance = parseUnits(String(tokens), 18);

  await fetch(rpcUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'anvil_setBalance',
      params: [address, `0x${ethBalance.toString(16)}`],
    }),
  });

  await walletClient.writeContract({
    abi,
    address: addresses.baseToken,
    functionName: 'mint',
    args: [address, tokenBalance],
  });
}

process.exit(0);
