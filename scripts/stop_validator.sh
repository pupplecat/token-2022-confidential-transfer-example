#!/bin/bash
  [ -f validator.pid ] && kill $(cat validator.pid) && rm -f validator.pid
  rm -rf test-ledger
  echo "Validator stopped and cleaned up."