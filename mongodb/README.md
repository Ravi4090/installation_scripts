
# MongoDB Replica Set Setup with Docker Compose

This guide explains how to set up a MongoDB replica set with three nodes using Docker Compose, initialize the replica set, verify its status, and connect externally (e.g., via MongoDB Compass).

---

## Prerequisites

- Docker and Docker Compose installed on your server
- Access to the server’s public or private IP (for external connections)
- MongoDB keyfile created and placed on the host with proper permissions

---

## 1. Prepare MongoDB Keyfile

1. Create a keyfile to enable internal authentication between replica set members.

```bash
openssl rand -base64 756 > mongo-keyfile
chmod 400 mongo-keyfile
````

2. Place the `mongo-keyfile` on your host machine, e.g., `/home/ubuntu/mongo-keyfile`.

---

## 2. Docker Compose Configuration

Create a `docker-compose.yaml` with three MongoDB nodes:

```yaml
version: "3.8"

services:
  mongo1:
    image: mongo:7.0
    container_name: mongo1
    ports:
      - "27017:27017"
    command: ["mongod", "--replSet", "rs0", "--bind_ip_all", "--keyFile", "/data/configdb/mongo-keyfile"]
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - mongo1_data:/data/db
      - /home/ubuntu/mongo-keyfile:/data/configdb/mongo-keyfile
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  mongo2:
    image: mongo:7.0
    container_name: mongo2
    ports:
      - "27018:27017"
    command: ["mongod", "--replSet", "rs0", "--bind_ip_all", "--keyFile", "/data/configdb/mongo-keyfile"]
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - mongo2_data:/data/db
      - /home/ubuntu/mongo-keyfile:/data/configdb/mongo-keyfile
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  mongo3:
    image: mongo:7.0
    container_name: mongo3
    ports:
      - "27019:27017"
    command: ["mongod", "--replSet", "rs0", "--bind_ip_all", "--keyFile", "/data/configdb/mongo-keyfile"]
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    volumes:
      - mongo3_data:/data/db
      - /home/ubuntu/mongo-keyfile:/data/configdb/mongo-keyfile
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  mongo1_data:
  mongo2_data:
  mongo3_data:
```

---

## 3. Start MongoDB Replica Set Containers

```bash
docker-compose up -d
```

Check that all containers are running:

```bash
docker ps
```

---

## 4. Initialize the Replica Set

1. Connect to the primary container:

```bash
docker exec -it mongo1 mongosh -u root -p example --authenticationDatabase admin
```

2. Initialize the replica set with external IP addresses (replace `YOUR_SERVER_IP`):

```js
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "YOUR_SERVER_IP:27017" },
    { _id: 1, host: "YOUR_SERVER_IP:27018" },
    { _id: 2, host: "YOUR_SERVER_IP:27019" }
  ]
})
```

> **Note:** Use your server's IP so clients outside Docker can connect.

3. Confirm the replica set status:

```js
rs.status()
```

Look for:

* One PRIMARY node
* Two SECONDARY nodes
* No errors in health or sync messages

---

## 5. Test Replica Set Operations

Inside the primary container shell (`mongosh`):

```js
use test
db.testCollection.insertOne({ message: "Hello Replica Set" })
db.testCollection.find()
```

Verify the write and read operations succeed.

---

## 6. Connect Externally via MongoDB Compass or `mongosh`

Use this connection string (replace `YOUR_SERVER_IP` and credentials):

```bash
mongodb://root:example@YOUR_SERVER_IP:27017,YOUR_SERVER_IP:27018,YOUR_SERVER_IP:27019/?replicaSet=rs0&authSource=admin
```

Example:

```
mongodb://root:example@16.16.144.101:27017,16.16.144.101:27018,16.16.144.101:27019/?replicaSet=rs0&authSource=admin
```

---

## 7. (Optional) Reconfigure Replica Set to Use External IP

If you initially configured using Docker hostnames (e.g., `mongo1:27017`), you can update to your server IP:

```js
cfg = rs.conf()
cfg.members[0].host = "YOUR_SERVER_IP:27017"
cfg.members[1].host = "YOUR_SERVER_IP:27018"
cfg.members[2].host = "YOUR_SERVER_IP:27019"
rs.reconfig(cfg, { force: true })
```

---

## 8. Important Notes

* **Keyfile permissions**: Ensure the keyfile has restricted permissions (`chmod 400 mongo-keyfile`).
* **Authentication**: Internal authentication between nodes relies on the keyfile.
* **Restart policy**: `restart: always` ensures containers restart on failure or server reboot.
* **Logging**: Configured with rotation limits to avoid large disk usage.
* **Ports**: 27017, 27018, 27019 are mapped to host ports for external access.

---

## Troubleshooting

* If replica set members cannot sync, check logs for authentication errors.
* Verify container network connectivity.
* Confirm IP addresses used in replica set config match your server IP.

---

## Summary

You now have a working 3-node MongoDB replica set running on Docker Compose, accessible externally with authentication, logging, and automatic restarts.

---

