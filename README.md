# Token-2022 Confidential Transfer Example

This repository demonstrates the Token2022 Confidential Transfer (CT) Extension using two approaches:

1. Shell scripts for a step-by-step demo.
2. Rust examples for programmatic interaction.

**Related Talk**: [Token-2022 Confidential Transfer Talk](https://github.com/pupplecat/token-2022-confidential-transfer-talk)

## Run from Shell Scripts

### 1. Prerequisites

- Install the Solana CLI. Follow the [official installation guide](https://solana.com/docs/intro/installation).
- Ensure your local environment is set up to run a Solana test validator.

### 2. Run Scripts

Follow these steps to execute the Confidential Transfer demo:

```bash
# 🪀 Start the local validator node in the background
sh ./scripts/start_validator.sh

# Run the Confidential Transfer demo step-by-step
sh ./scripts/demo_ct.sh

# 🏓 Stop the validator node and clean up generated files
sh ./scripts/stop_validator.sh
```

**Note**: The `demo_ct.sh` script walks you through the process interactively, including creating a mint, setting up accounts, depositing, transferring, and withdrawing tokens confidentially.

## Run from Rust Examples

The Rust examples are adapted from the [Solana Confidential Transfer documentation](https://solana.com/docs/tokens/extensions/confidential-transfer). They demonstrate the same workflow programmatically.

### 1. Prerequisites

- Install Rust and Cargo if not already installed. See [Rust installation](https://www.rust-lang.org/tools/install).
- Ensure the Solana CLI is installed (see above).

### 2. Run Rust Examples

Execute the following commands in sequence:

```bash
# 🪀 Start the local validator node in the background
sh ./scripts/start_validator.sh

# Create a mint with confidential transfer enabled
cargo run --bin 1_create_mint

# Create token accounts for sender and receiver
cargo run --bin 2_create_token_accounts

# Deposit tokens into the sender's confidential balance
cargo run --bin 3_deposit_tokens

# Apply the sender's pending balance
cargo run --bin 4_apply_pending_balance

# Transfer tokens confidentially from sender to receiver
cargo run --bin 5_transfer_tokens

# Apply the receiver's pending balance
cargo run --bin 6_apply_pending_balance_receiver

# Withdraw tokens from the receiver's confidential balance
cargo run --bin 7_withdraw_tokens

# 🏓 Stop the validator node and clean up generated files
sh ./scripts/stop_validator.sh
```

**Note**: Ensure each `cargo run` command completes successfully before proceeding to the next step. The bin names above assume a typical naming convention; adjust them to match your actual binary names if different.

## View on Solana Explorer

After running the demo, you can inspect the accounts and transactions on Solana Explorer:

- [Solscan](https://solscan.io/?cluster=custom&customUrl=http%3A%2F%2Flocalhost%3A8899)

The `demo_ct.sh` script provides a URL to view the receiver's account directly in Solscan, showing the encrypted balance fields.
