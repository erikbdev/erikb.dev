# ================================
# Build Web
# ================================
FROM node:24-bookworm-slim AS web-builder

RUN corepack enable && corepack prepare pnpm@10.33.2 --activate

WORKDIR /build

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm generate

# ================================
# Build Site Server
# ================================
FROM swift:6.3-bookworm AS server-builder

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve \
        $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . .

RUN swift build -c release \
        --product SiteServer \
        --static-swift-stdlib \
        -Xlinker -ljemalloc

WORKDIR /staging

RUN cp "$(swift build --package-path /build -c release --show-bin-path)/SiteServer" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;
COPY --from=web-builder /build/.output/public ./public

# ================================
# Deploy
# ================================
FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install -y \
    libjemalloc2 \
    ca-certificates \
    tzdata \
    libcurl4 \
    && rm -r /var/lib/apt/lists/*

RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /server deploy

WORKDIR /server

COPY --from=server-builder --chown=deploy:deploy /staging /server

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

USER deploy:deploy

EXPOSE 8080

ENTRYPOINT ["./SiteServer"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]
