#!/usr/bin/env bash
# Builds this Hugo site on Cloudflare Workers.
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.148.2}"
HUGO_CACHEDIR="${PWD}/.cache/hugo"
export HUGO_CACHEDIR

build_temp_dir=$(mktemp -d)
cleanup() { rm -rf "${build_temp_dir}"; }
trap cleanup EXIT

mkdir -p "${HOME}/.local/hugo"

# PaperMod needs Hugo >= 0.146; use extended for image processing.
echo "Installing Hugo extended ${HUGO_VERSION}..."
curl -sfL --output-dir "${build_temp_dir}" -O \
  "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
tar -C "${HOME}/.local/hugo" -xf \
  "${build_temp_dir}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
export PATH="${HOME}/.local/hugo:${PATH}"

echo "Hugo: $(hugo version)"

if [[ "$(git rev-parse --is-shallow-repository)" == "true" ]]; then
  echo "Fetching full Git history..."
  git fetch --unshallow
fi

if [[ -f .gitmodules ]]; then
  git submodule update --init --recursive
fi

echo "Building site..."
hugo --gc --minify
