# Drosera Trap Foundry Template

This repo is for quickly bootstrapping a new Drosera project. It includes instructions for creating your first trap, deploying it to the Drosera network, and updating it on the fly.

[![view - Documentation](https://img.shields.io/badge/view-Documentation-blue?style=for-the-badge)](https://dev.drosera.io "Project documentation")

## Configure dev environment

```bash
# install forge
rustup update stable
curl -L https://foundry.paradigm.xyz | bash

# install vscode (optional)
# - add solidity extension JuanBlanco.solidity

# install drosera-cli
TODO: Add instructions for installing drosera-cli
```

open the VScode preferences and Select `Soldity: Change workpace compiler version (Remote)`

Select version `0.8.12`

## User Quick Start Guide

[User Quick Start Guide](./UserQuickStart.md)

## Build Traps

```bash
forge build
```

## Testing

```bash
forge test
```
