#!/bin/bash
set -e

# Persistent data directory (bind mount or volume)
DATA_DIR="/data"

# If /data is empty, populate it with initial data from the image
if [ ! -f "$DATA_DIR/.initialized" ]; then
    echo "First run - copying initial data to persistent volume..."

    # Copy persistent data (preserving existing data if any)
    for dir in world config defaultconfigs kubejs; do
        if [ -d "/app/$dir" ] && [ ! -d "$DATA_DIR/$dir" ]; then
            cp -r "/app/$dir" "$DATA_DIR/"
        fi
    done

    for file in banned-ips.json banned-players.json ops.json whitelist.json \
                usercache.json usernamecache.json server.properties eula.txt; do
        if [ -f "/app/$file" ] && [ ! -f "$DATA_DIR/$file" ]; then
            cp "/app/$file" "$DATA_DIR/"
        fi
    done

    # Copy logs if they exist
    if [ -d "/app/logs" ] && [ ! -d "$DATA_DIR/logs" ]; then
        cp -r "/app/logs" "$DATA_DIR/"
    fi

    touch "$DATA_DIR/.initialized"
fi

# Symlink persistent data into /app
rm -rf /app/world /app/config /app/defaultconfigs /app/kubejs \
       /app/banned-ips.json /app/banned-players.json /app/ops.json \
       /app/whitelist.json /app/usercache.json /app/usernamecache.json \
       /app/server.properties /app/eula.txt /app/logs

ln -s "$DATA_DIR/world" /app/world
ln -s "$DATA_DIR/config" /app/config
ln -s "$DATA_DIR/defaultconfigs" /app/defaultconfigs
ln -s "$DATA_DIR/kubejs" /app/kubejs
ln -s "$DATA_DIR/banned-ips.json" /app/banned-ips.json
ln -s "$DATA_DIR/banned-players.json" /app/banned-players.json
ln -s "$DATA_DIR/ops.json" /app/ops.json
ln -s "$DATA_DIR/whitelist.json" /app/whitelist.json
ln -s "$DATA_DIR/usercache.json" /app/usercache.json
ln -s "$DATA_DIR/usernamecache.json" /app/usernamecache.json
ln -s "$DATA_DIR/server.properties" /app/server.properties
ln -s "$DATA_DIR/eula.txt" /app/eula.txt
ln -s "$DATA_DIR/logs" /app/logs

# Accept EULA
echo "eula=true" > /app/eula.txt

# Run the server
cd /app
exec java $JAVA_OPTS @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.13/unix_args.txt nogui
