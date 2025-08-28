# Drosera Trap Foundry Template

This repo is for quickly bootstrapping a new Drosera project. It includes instructions for creating your first trap, deploying it to the Drosera network, and updating it on the fly.

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://dev.drosera.io "Project documentation")
[![Twitter](https://img.shields.io/twitter/follow/DroseraNetwork?style=for-the-badge)](https://x.com/DroseraNetwork)

## Configure dev environment

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup

# The trap-foundry-template utilizes node modules for dependency management
# install Bun (optional)
curl -fsSL https://bun.sh/install | bash

# install node modules
bun install

# install vscode (optional)
# - add solidity extension JuanBlanco.solidity

# install drosera-cli
curl -L https://app.drosera.io/install | bash
droseraup
```

open the VScode preferences and Select `Soldity: Change workpace compiler version (Remote)`

Select version `0.8.12`

## Quick Start

### Hello World Trap

The drosera.toml file is configured to deploy a simple "Hello, World!" trap. Ensure the drosera.toml file is set to the following configuration:

```toml
response_contract = "0xdA890040Af0533D98B9F5f8FE3537720ABf83B0C"
response_function = "helloworld(string)"
```

To deploy the trap, run the following commands:

```bash
# Compile the Trap
forge build

# Deploy the Trap
DROSERA_PRIVATE_KEY=0x.. drosera apply
```

After successfully deploying the trap, the CLI will add an `address` field to the `drosera.toml` file.

Congratulations! You have successfully deployed your first trap!

### Response Trap

You can then update the trap by changing its logic and recompling it or changing the path field in the `drosera.toml` file to point to the Response Trap.

The Response Trap is designed to trigger a response at a specific block number. To test the Response Trap, pick a future block number and update the Response Trap.
Specify a response contract address and function signature in the drosera.toml file to the following:

```toml
response_contract = "0x183D78491555cb69B68d2354F7373cc2632508C7"
response_function = "responseCallback(uint256)"
```

Finally, deploy the Response Trap by running the following commands:

```bash
# Compile the Trap
forge build

# Deploy the Trap
DROSERA_PRIVATE_KEY=0x.. drosera apply
```

> Note: The `DROSERA_PRIVATE_KEY` environment variable can be used to deploy traps. You can also set it in the drosera.toml file as `private_key = "0x.."`.


### Transfer Event Trap
The TransferEventTrap is an example of how a Trap can parse event logs from a block and respond to a specific ERC-20 token transfer events.

To deploy the Transfer Event Trap, uncomment the `transfer_event_trap` section in the `drosera.toml` file. Add the token address to the `tokenAddress` constant in the `TransferEventTrap.sol` file and then deploy the trap.

## Testing

Example tests are included in the `tests` directory. They simulate how Drosera Operators execute traps and determine if a response should be triggered. To run the tests, execute the following command:

```bash
forge test
```
