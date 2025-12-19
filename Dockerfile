# PowerNukkitX Docker Multi-Stage Build
# This Dockerfile uses Docker Multi-Stage Builds to create a minimal runtime image
# See https://docs.docker.com/engine/userguide/eng-image/multistage-build/
# Requires Docker v17.05+

# ==============================================================================
# Build Stage: Compile and package the server
# ==============================================================================
# Use Eclipse Temurin JDK 21 on Ubuntu Jammy as the build base
FROM eclipse-temurin:21-jdk-jammy AS build

# Set working directory for the build
WORKDIR /src

# Copy build configuration files and Git metadata
# Note: .git directory is needed for git-properties plugin
# Note: .gitmodules is needed for submodule initialization (if any exist)
COPY gradlew *.gradle.kts .gitmodules /src/
COPY src /src/src
COPY .git /src/.git
COPY gradle /src/gradle

# Install git for submodule support
# Clean apt cache to reduce layer size
RUN apt-get clean \
    && apt-get update \
    && apt install git -y \
    && rm -rf /var/lib/apt/lists/*

# Initialize git submodules (required for Terra generator and other dependencies)
RUN git submodule update --init

# Ensure gradlew script is executable
RUN chmod +x gradlew

# Build the shadow JAR (fat JAR with all dependencies)
# This may require access to external Maven repositories:
# - jitpack.io
# - repo.opencollab.dev  
# - repo.powernukkitx.org
# If build fails with connection errors, these domains may need to be allowlisted
RUN ./gradlew shadowJar --no-daemon

# ==============================================================================
# Runtime Stage: Minimal runtime environment
# ==============================================================================
# Use Eclipse Temurin JDK 21 (full JDK required, not JRE)
# PowerNukkitX requires JDK features at runtime
FROM eclipse-temurin:21-jdk-jammy AS run

# Create app directory and copy the built JAR from build stage
RUN mkdir /app
COPY --from=build /src/build/powernukkitx.jar /app/powernukkitx.jar

# Create non-root minecraft user for security
# - No home directory created initially
# - Home set to /data for server files
# - No login shell for security
RUN useradd --user-group \
            --no-create-home \
            --home-dir /data \
            --shell /usr/sbin/nologin \
            minecraft

# Expose Minecraft Bedrock Edition default port (UDP)
# Default port is 19132/udp
EXPOSE 19132

# Create directories for server data and minecraft user home
# /data - Server files, worlds, configs
# /home/minecraft - User home directory
RUN mkdir -p /data /home/minecraft

# Set ownership for all required directories
RUN chown -R minecraft:minecraft /app /data /home/minecraft

# Switch to non-root user for security
USER minecraft:minecraft

# Define volumes for persistent data
# /data - Server data, worlds, configurations
# /home/minecraft - User home for potential cache/temp files
VOLUME /data /home/minecraft

# Set working directory to data directory
# Server will create config files and worlds here
WORKDIR /data

# Run PowerNukkitX server with optimized JVM settings
ENTRYPOINT ["java"]
# JVM Arguments:
# - UTF-8 encoding for proper character handling
# - Jansi/ANSI terminal settings for console output
# - ZGC garbage collector with generational mode for better performance
# - String deduplication to reduce memory usage
# - --add-opens flags required for reflection access (as per README)
# - Classpath includes the JAR and any external libs in ./libs/
CMD [ "-Dfile.encoding=UTF-8", \
      "-Djansi.passthrough=true", \
      "-Dterminal.ansi=true", \
      "-XX:+UseZGC", \
      "-XX:+ZGenerational", \
      "-XX:+UseStringDeduplication", \
      "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
      "--add-opens", "java.base/java.io=ALL-UNNAMED", \
      "-cp", "/app/powernukkitx.jar:./libs/*", \
      "cn.nukkit.Nukkit" ]
