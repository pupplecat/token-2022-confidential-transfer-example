#!/bin/bash

# Exit on error
set -e

# Token2022 Program ID
TOKEN2022_PROGRAM_ID="TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"

# Verify validator is running
if ! pgrep -f solana-test-validator; then
  echo "================================================================="
  echo "ERROR: Validator not running. Please start it with './start_validator.sh'."
  echo "================================================================="
  exit 1
fi

# Create admin keypair for mint authority if it doesn't exist
[ -f ./admin.json ] || solana-keygen new -o ./admin.json --no-bip39-passphrase
# Fund admin account
solana airdrop 2 ./admin.json

# Step 1: Create confidential mint and capture the mint address
echo "================================================================="
echo "STEP 1: CREATING A CONFIDENTIAL MINT"
echo "================================================================="
echo "Creating a confidential mint..."
set +e
# Use admin.json as the mint authority
MINT_OUTPUT=$(spl-token --program-id $TOKEN2022_PROGRAM_ID create-token --enable-confidential-transfers auto --decimals 2 --owner ./admin.json 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -ne 0 ]; then
  echo "Error creating mint: $MINT_OUTPUT"
  echo "Please ensure Token2022 program is loaded and CLI version supports CT."
  exit 1
fi
MINT_ADDRESS=$(echo "$MINT_OUTPUT" | grep 'Creating token' | grep -o '[[:alnum:]]\{44\}')
if [ -z "$MINT_ADDRESS" ]; then
  echo "Failed to retrieve mint address. Raw output: $MINT_OUTPUT"
  exit 1
fi
echo "Mint Address: $MINT_ADDRESS"
spl-token --program-id $TOKEN2022_PROGRAM_ID display $MINT_ADDRESS
read -p "Press Enter to see the mint address..."

# Step 2: Set up accounts
echo "================================================================="
echo "STEP 2: SETTING UP SENDER AND RECEIVER ACCOUNTS"
echo "================================================================="
echo "Setting up sender and receiver accounts..."
# Create sender and receiver keypairs if not exist
[ -f ./sender.json ] || solana-keygen new -o ./sender.json --no-bip39-passphrase
[ -f ./receiver.json ] || solana-keygen new -o ./receiver.json --no-bip39-passphrase

# Fund both sender and receiver
solana airdrop 2 ./sender.json
solana airdrop 2 ./receiver.json

# Create token accounts for sender and receiver, capturing addresses directly
SENDER_OUTPUT=$(spl-token --program-id $TOKEN2022_PROGRAM_ID create-account $MINT_ADDRESS --owner ./sender.json 2>&1)
SENDER_ACCOUNT=$(echo "$SENDER_OUTPUT" | grep 'Creating account' | grep -o '[[:alnum:]]\{44\}')
if [ -z "$SENDER_ACCOUNT" ]; then
  echo "Failed to retrieve sender account address. Raw output: $SENDER_OUTPUT"
  exit 1
fi

RECEIVER_OUTPUT=$(spl-token --program-id $TOKEN2022_PROGRAM_ID create-account $MINT_ADDRESS --owner ./receiver.json 2>&1)
RECEIVER_ACCOUNT=$(echo "$RECEIVER_OUTPUT" | grep 'Creating account' | grep -o '[[:alnum:]]\{44\}')
if [ -z "$RECEIVER_ACCOUNT" ]; then
  echo "Failed to retrieve receiver account address. Raw output: $RECEIVER_OUTPUT"
  exit 1
fi

# Configure accounts for confidential transfers with specific addresses
spl-token --program-id $TOKEN2022_PROGRAM_ID configure-confidential-transfer-account --address $SENDER_ACCOUNT --owner ./sender.json
spl-token --program-id $TOKEN2022_PROGRAM_ID configure-confidential-transfer-account --address $RECEIVER_ACCOUNT --owner ./receiver.json

echo "Sender Account: $SENDER_ACCOUNT"
echo "Receiver Account: $RECEIVER_ACCOUNT"
spl-token --program-id $TOKEN2022_PROGRAM_ID display $SENDER_ACCOUNT
read -p "Press Enter to see the configured accounts..."

# Step 3: Deposit to encrypted balance
echo "================================================================="
echo "STEP 3: DEPOSITING 100 TOKENS TO SENDER'S ENCRYPTED BALANCE"
echo "================================================================="
echo "Minting 100 tokens to sender's account..."
spl-token --program-id $TOKEN2022_PROGRAM_ID mint $MINT_ADDRESS 100 $SENDER_ACCOUNT --owner ./admin.json
spl-token --program-id $TOKEN2022_PROGRAM_ID balance --address $SENDER_ACCOUNT
# Debug: Check token account state
echo "Checking sender account state..."
spl-token --program-id $TOKEN2022_PROGRAM_ID display $SENDER_ACCOUNT
# Deposit confidential tokens
echo "Depositing 100 tokens to confidential transfer extension..."
spl-token --program-id $TOKEN2022_PROGRAM_ID deposit-confidential-tokens $MINT_ADDRESS 100 --address $SENDER_ACCOUNT --owner ./sender.json
echo "Checking sender account state after deposit..."
spl-token --program-id $TOKEN2022_PROGRAM_ID display $SENDER_ACCOUNT
read -p "Press Enter to apply the pending balance..."

# Step 4: Apply pending balance (Sender)
echo "================================================================="
echo "STEP 4: APPLYING PENDING BALANCE FOR SENDER"
echo "================================================================="
echo "Applying pending balance for sender..."
spl-token --program-id $TOKEN2022_PROGRAM_ID apply-pending-balance --address $SENDER_ACCOUNT --owner ./sender.json
echo "Checking sender account state after applying pending balance..."
spl-token --program-id $TOKEN2022_PROGRAM_ID display $SENDER_ACCOUNT
read -p "Press Enter to transfer tokens to receiver..."

# Step 5: Transfer (amount hidden)
echo "================================================================="
echo "STEP 5: TRANSFERRING 20 TOKENS CONFIDENTIALLY TO RECEIVER"
echo "================================================================="
echo "Transferring 20 tokens confidentially to receiver..."
spl-token --program-id $TOKEN2022_PROGRAM_ID transfer $MINT_ADDRESS 20 $RECEIVER_ACCOUNT --confidential --owner ./sender.json
read -p "Press Enter to see the receiver's pending balance..."

# Step 6: Apply pending balance (Receiver)
echo "================================================================="
echo "STEP 6: APPLYING PENDING BALANCE FOR RECEIVER"
echo "================================================================="
echo "Applying pending balance for receiver..."
spl-token --program-id $TOKEN2022_PROGRAM_ID apply-pending-balance --address $RECEIVER_ACCOUNT --owner ./receiver.json
echo "Checking receiver account state after applying pending balance..."
spl-token --program-id $TOKEN2022_PROGRAM_ID display $RECEIVER_ACCOUNT
read -p "Press Enter to withdraw receiver tokens..."

# Step 7: Withdraw tokens (Receiver)
echo "================================================================="
echo "STEP 7: WITHDRAWING CONFIDENTIAL TOKENS FROM RECEIVER"
echo "================================================================="
echo "Withdrawing 20 confidential tokens from receiver..."
spl-token --program-id $TOKEN2022_PROGRAM_ID withdraw-confidential-tokens $MINT_ADDRESS 20 --address $RECEIVER_ACCOUNT --owner ./receiver.json
echo "Checking receiver account state after withdrawal..."
spl-token --program-id $TOKEN2022_PROGRAM_ID display $RECEIVER_ACCOUNT
read -p "Press Enter to view in Solana Explorer..."

# Step 8: Check Solana Explorer (simulated)
echo "================================================================="
echo "STEP 8: CHECKING ENCRYPTED BALANCE (SOLANA EXPLORER)"
echo "================================================================="
echo "Explorer URL: https://solscan.io/account/$RECEIVER_ACCOUNT?cluster=custom&customUrl=http://localhost:8899"
echo "Notice the pending_balance field—it's encrypted! In the Explorer, you'd see this hidden."
read -p "Press Enter to continue..."

echo "================================================================="
echo "DEMO COMPLETE! 🈲🈲🈲 Stop the validator with './stop_validator.sh'."
echo "================================================================="