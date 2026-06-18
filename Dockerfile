# Use a Java 17 base (required for Minecraft 1.20)
FROM eclipse-temurin:17-jdk-jammy

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy server files
COPY user_jvm_args.txt .
COPY run.sh .
COPY eula.txt .
COPY server.properties .

# Copy directories that DON'T need to persist (they ship with the image)
COPY mods mods/
COPY libraries libraries/
COPY resourcepacks resourcepacks/
COPY patchouli_books patchouli_books/
COPY fancymenu_data fancymenu_data/

# Copy initial data for persistent directories
# These will be copied to /data on first run
COPY world world/
COPY config config/
COPY defaultconfigs defaultconfigs/
COPY kubejs kubejs/
COPY banned-ips.json banned-ips.json
COPY banned-players.json banned-players.json
COPY ops.json ops.json
COPY whitelist.json whitelist.json
COPY usercache.json usercache.json
COPY usernamecache.json usernamecache.json

# Create entrypoint script
RUN chmod +x run.sh

# Expose Minecraft server port
EXPOSE 25565

# Set memory (adjust as needed)
ENV JAVA_OPTS="-Xmx6G -Xms4G"

# Entrypoint that handles persistent data
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
