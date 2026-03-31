#!/bin/bash
set -e

CONFIG=${1:-debug}

swift package \
  --swift-sdk swift-6.3-RELEASE_wasm-embedded \
  --toolset utils/embedded-toolset.json \
  js \
  -c $CONFIG \
  --use-cdn \
  --product SiteApp \
  --default-platform browser \
  --output public/assets/wasm
