# Minato Node Setup

This guide provides instructions on setting up a Minato node using Docker, Docker Compose, and binary installation.

## Hardware requirement
We recommend using the `i3.2xlarge` AWS instance type or equivalent hardware. If you want to set it up as a public RPC, you will need to adjust node resources based on your traffic.

---------------------------
# Docker installation

## Prerequisites

- **Docker**: Ensure Docker is installed on your system. You can install it by following the instructions [here](https://docs.docker.com/get-docker/).
- **Docker Compose**: Ensure Docker Compose is installed on your system. You can install it by following the instructions [here](https://docs.docker.com/compose/install/).

Make sure you have the latest versions of Docker and Docker Compose installed.

## Setup Instructions

1. **Generate JWT Secret**

   Generate a JWT secret by running the following command:

   ```bash
   openssl rand -hex 32 > jwt.txt
   ```

2. **Rename Environment File**

   Rename `sample.env` to `.env`:

   ```bash
   mv sample.env .env
   ```

3. **Update Environment Variables**

   Open the `.env` file in a text editor and update the following variables:

   ```bash
   L1_URL=https://sepolia-l1.url 
   L1_BEACON=https://sepolia-beacon-l1.url
   P2P_ADVERTISE_IP=<Node Public IP>
   ```

In some node providers, you need to specify your node's public IP for `op-geth`. To do this, replace `<your_node_public_ip>` with your actual public IP in the `--nat=extip:<your_node_public_ip>` parameter within the `docker-compose.yml` file, specifically under the `op-geth-minato` service settings. 

   <b>Recommendation: For faster synchronization, it's recommended to have the L1 node geographically close to the Minato node.</b>

4. **Run Docker Compose**

   Run the Docker Compose file to start the services:

   ```bash
   docker-compose up -d
   ```

5. **Check Logs**

   Monitor the logs to ensure the services are running correctly:

   - For `op-node-minato`:
     ```bash
     docker-compose logs -f op-node-minato
     ```
   <img width="1123" alt="Screenshot 1403-06-02 at 18 53 12" src="https://github.com/user-attachments/assets/c2500a17-e31a-4d50-a8c5-54d36071fdb5">

  - For `op-geth-minato`:
     ```bash
     docker-compose logs -f op-geth-minato
     ```
     <img width="1128" alt="Screenshot 1403-06-02 at 18 53 33" src="https://github.com/user-attachments/assets/218a16c2-f610-4985-96fd-447c52f54bdc">

After each restart, it takes approximately 2 minutes for the node to start syncing.

---------------------------
# Binary installation

## Prerequisites

- Ubuntu 22.04 or a compatible Linux distribution.
- Root or sudo privileges.
- OpenSSL installed.

## Installation Steps

### Step 1: Download Binaries

Download the `op-node` and `geth` binaries from the release page:

```bash
wget https://github.com/Soneium/soneium-node/releases/download/v1.9.0-ec45f663-1723023640/op-node
wget https://github.com/Soneium/soneium-node/releases/download/v1.101315.3-stable-8af19cf2/geth
```

### Step 2: Set Executable Permissions
Make the downloaded binaries executable:

```bash
chmod +x op-node geth
```

### Step 3: Move Binaries to `/usr/local/bin`
Move the binaries to `/usr/local/bin` for easy execution:

```bash
sudo mv -t /usr/local/bin geth op-node
```

### Step 4: Set Up Configuration
Create the necessary directories and generate the JWT secret:

```bash
sudo mkdir /etc/optimism
openssl rand -hex 32 > jwt.txt
git clone git@github.com:Web3-Technology-Planning-Office-SNCLabs/soneium-node.git
cd soneium-node/minato
openssl rand -hex 32 > jwt.txt
sudo mv -t /etc/optimism/ minato-genesis.json jwt.txt minato-rollup.json
```

### Step 5: Initialize Geth
Initialize `geth` with the genesis configuration:

```bash
sudo geth init --datadir=/data/optimism/ /etc/optimism/genesis.json
```

## Service Configuration

<b>`op-node` Service</b>
Create a systemd service for op-node:

```bash
sudo nano /etc/systemd/system/op-node.service
```

Add the following content:

```bash
[Unit]
Description=op-node
After=network-online.target
Wants=network-online.target

[Service]
User=root
Group=root
Type=simple

ExecStart=/usr/local/bin/op-node \
  --l1=https://sepolia-l1.url \
  --l2=http://localhost:8551 \
  --rpc.addr=127.0.0.1 \
  --rpc.port=9545 \
  --l2.jwt-secret=/etc/optimism/jwt.txt \
  --l1.trustrpc \
  --l1.beacon=https://beacon-l1.url \
  --syncmode=execution-layer \
  --l1.rpckind=erigon \
  --p2p.priv.path=/etc/optimism/p2p.key \
  --p2p.static=/dns4/peering-01.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAm36ufaFmS3tjSjkUnwSJmQN8W8fZ8yXiu2AYL2o11EgcK,/dns4/peering-02.prd.hypersonicl2.com/tcp/9222/p2p/16Uiu2HAmPkRbG8kkhJ3JWmrqeiMvy1hWXFSz4s4rncVe8YiCJHmx \
  --p2p.discovery.path=/etc/optimism/p2p.db \
  --p2p.peerstore.path=/etc/optimism/p2p-peerstore.db \
  --metrics.enabled \
  --p2p.advertise.ip=<your-public-ip> \
  --metrics.port=7310 \
  --rollup.config=/etc/optimism/rollup.json

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

<b>`op-geth` Service</b>
Create a systemd service for `geth`:

```bash
sudo nano /etc/systemd/system/op-geth.service
```

Add the following content:

```bash
[Unit]
Description=op-geth
After=network-online.target
Wants=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/geth \
  --datadir=/data/optimism \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.api=web3,debug,eth,txpool,net,engine \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=debug,eth,txpool,net,engine \
  --syncmode=full \
  --gcmode=archive \
  --maxpeers=100 \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=/etc/optimism/jwt.txt \
  --metrics \
  --metrics.addr=0.0.0.0 \
  --metrics.expensive \
  --metrics.port=6060 \
  --rollup.disabletxpoolgossip=false \
  --rpc.allow-unprotected-txs=true \
  --nat=extip:<your_node_public_ip> \
  --db.engine=pebble \
  --state.scheme=hash \
  --bootnodes=enode://6526c348274c54e7b4184014741897eb25e12ca388f588b0265bb2246caeea87ed5fcb2d55b7b08a90cd271a53bc76decb6d1ec37f219dbe4cd3ed53a888118b@peering-02.prd.hypersonicl2.com:30303,enode://34f172c255b11f64828d73c90a60395691e89782639423d434385594dd38b434ddffb78ad411da6fd37cbda6d0f93e17ceae399ac4f2594b0d54eb8c83c27de9@peering-01.prd.hypersonicl2.com:30303"

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Step 6: Enable and Start Services
Enable and start the services to run at boot:

```bash
sudo systemctl enable op-node.service
sudo systemctl start op-node.service

sudo systemctl enable op-geth.service
sudo systemctl start op-geth.service
```

# Disclaimer

We’re eager for you to start building on Soneium, but it's important that you fully understand the details of the node software and smart contracts provided here.

THIS SOFTWARE IS PROVIDED ON AN “AS IS WHERE IS” BASIS WITHOUT ANY REPRESENTATION OR WARRANTY, OF ANY KIND, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. WE MAKE NO REPRESENTATION, WARRANTY, UNDERTAKING, GUARANTEE OR ASSURANCE WITH RESPECT TO THIS SOFTWARE, INCLUDING BUT NOT LIMITED THAT IT IS SECURE, OR ERROR-FREE, OR FREE OF VULNERABILITIES OR VIRUSES OR BUGS.
YOUR USE OF THE SOFTWARE IS AT YOUR SOLE RISK. YOU SHOULD CONDUCT YOUR OWN INDEPENDENT DUE DILIGENCE AND COMPLY WITH ALL APPLICABLE LAWS. WE ARE NOT RESPONSIBLE FOR ANY LOSSES OR DAMAGES WHATSOEVER THAT YOU SUFFER OR INCUR FROM USING THE SOFTWARE.
