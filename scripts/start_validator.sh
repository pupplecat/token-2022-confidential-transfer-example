#!/bin/bash
solana config set --url localhost

solana-test-validator -r -q \
  --clone-upgradeable-program TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb \
  --url https://api.mainnet-beta.solana.com &

echo $! > validator.pid
sleep 5
if ! pgrep -f solana-test-validator; then
  echo "Validator failed to start."
  exit 1
fi
echo "Validator started. PID stored in validator.pid"
