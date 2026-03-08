# ================================
# Build image
# ================================
FROM swift:6.2-bookworm AS build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

# Copy entire repo into container
COPY . .

# Build the application, with optimizations, with static linking, and using jemalloc
# N.B.: The static version of jemalloc is incompatible with the static Swift runtime.
RUN swift build -c release \
        --product Server \
        --static-swift-stdlib \
        -Xlinker -ljemalloc

RUN swift build -c release \
        --product SSHServer \
        --static-swift-stdlib \
        -Xlinker -ljemalloc

# Switch to the staging area
WORKDIR /staging

# Copy HTTP Server executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Server" ./

# Copy SSH Server exutable to staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/SSHServer" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Copy any resources from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
# RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true

# ================================
# Run HTTP Image
# ================================
FROM debian:bookworm-slim AS deploy-http

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
    && rm -r /var/lib/apt/lists/*

# Create a deploy user and group with /server as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /server deploy

# Switch to the new home directory
WORKDIR /server

# Copy built executable and any staged resources from builder
COPY --from=build --chown=deploy:deploy /staging /server

# Provide configuration needed by the built-in crash reporter and some sensible default behaviors.
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Ensure all further commands run as the deploy user
USER deploy:deploy

# Let Docker bind to port 8080
EXPOSE 8080

# Start the service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./Server"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]

# ================================
# Run SSH Image
# ================================
FROM debian:bookworm-slim AS deploy-ssh

# Make sure all system packages are up to date, and install only essential packages.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
    && rm -r /var/lib/apt/lists/*

# Create a deploy user and group with /server as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /server deploy

# Switch to the new home directory
WORKDIR /server

# Copy built executable and any staged resources from builder
COPY --from=build --chown=deploy:deploy /staging /server

# Provide configuration needed by the built-in crash reporter and some sensible default behaviors.
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Ensure all further commands run as the deploy user
USER deploy:deploy

# Let Docker bind to port 8080
EXPOSE 8080

# Start the service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./SSHServer"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]