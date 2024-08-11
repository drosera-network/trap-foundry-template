# Drosera Trap Foundry Template

This repo is for quickly bootstrapping a new Drosera project. It includes instructions for creating your first trap, deploying it to the Drosera network, and updating it on the fly.

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://dev.drosera.io "Project documentation")

## Configure dev environment

```bash
# install forge
rustup update stable
curl -L https://foundry.paradigm.xyz | bash
foundryup

# install vscode (optional)
# - add solidity extension JuanBlanco.solidity

# install drosera-cli
curl https://raw.githubusercontent.com/drosera-network/releases/feat/droseraup/install/install | bash
droseraup
```

open the VScode preferences and Select `Soldity: Change workpace compiler version (Remote)`

Select version `0.8.12`

## Quick Start
The drosera.toml file is configured to deploy a simple "Hello, World!" trap. To deploy the trap, run the following commands:
```bash
# Compile the Trap
forge build

# Deploy the Trap
DROSERA_PRIVATE_KEY=0x.. drosera apply
```

After successfully deploying the trap, the CLI will add an `address` field to the `drosera.toml` file. You can then update the trap by changing its logic and recompling it or changing the path field in the `drosera.toml` file to point to the Alert Trap.

The Alert Trap is designed to trigger a response at a specific block number. To test the Alert Trap, pick a future block number and update the Alert Trap. Then specify a response contract address and function signature in the drosera.toml file. Finally, deploy the Alert Trap by running `drosera apply`. For example
```toml
response_contract = 0x...
response_function = "alert(uint32)"
```

> Note: The `DROSERA_PRIVATE_KEY` environment variable is required to deploy the trap. You can also set it in the drosera.toml file as `private_key = "0x.."`.

## Testing
Example tests are included in the `tests` directory. They simulate how Drosera Operators execute traps and determine if a response should be triggered. To run the tests, execute the following command:
```bash
forge test
```
