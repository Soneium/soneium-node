# Minato Node Setup

This guide provides instructions on setting up a Minato node using Docker and Docker Compose.

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
