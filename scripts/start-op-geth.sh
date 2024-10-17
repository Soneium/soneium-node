#!/bin/sh
set -e

# Init genesis if custom chain
if [ ! -s "${DATADIR}/geth_initialised" ]; then
  geth init --datadir=/data /chainconfig/genesis.json
  mkdir -p ${DATADIR}/p2p/
fi

# Start op-geth.
exec geth \
  --datadir="$DATADIR" \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=web3,debug,eth,txpool,net,engine \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=debug,eth,txpool,net,engine,web3 \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=$DATADIR/jwt.txt \
  --syncmode=snap \
  --port=30303 \
  --discovery.port=30304 \
  --nat=extip:$(wget -qO- https://api4.ipify.org) \
  --bootnodes=$(cat /chainconfig/opgeth_bootnodes.txt)
