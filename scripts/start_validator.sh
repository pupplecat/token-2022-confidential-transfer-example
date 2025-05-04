#!/bin/bash
solana config set --url localhost
solana-test-validator --reset --quiet &
echo $! > validator.pid
sleep 5
if ! pgrep -f solana-test-validator; then
  echo "Validator failed to start."
  exit 1
fi
echo "Validator started. PID stored in validator.pid"
