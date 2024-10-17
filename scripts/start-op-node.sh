#!/bin/sh
set -e

# Start op-node.
exec op-node \
  --l1=$L1_EXECUTION_URL \
  --l1.beacon=$L1_BEACON_URL \
  --l1.trustrpc \
  --l2=http://op-geth:8551 \
  --l2.jwt-secret=$DATADIR/jwt.txt \
  --rollup.config=/chainconfig/rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --syncmode=execution-layer \
  --log.level=debug \
  --p2p.bootnodes=$(cat /chainconfig/opnode_bootnodes.txt)
