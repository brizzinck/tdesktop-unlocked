#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
IMAGE_TAG="tdesktop:centos_env"
CENTOS_ENV="$REPO_ROOT/Telegram/build/docker/centos_env"

cd "$REPO_ROOT"

if ! docker image inspect "$IMAGE_TAG" &>/dev/null; then
    echo "==> Building Docker image (first time, takes ~30-60 min)..."
    export PATH="$HOME/.local/bin:$PATH"
    if ! which poetry &>/dev/null; then
        if which pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm python-pipx
            pipx install poetry
        else
            pipx install poetry
        fi
    fi
    cd "$CENTOS_ENV"
    poetry install --quiet
    DOCKERFILE=$(DEBUG= LTO= poetry run gen_dockerfile)
    echo "$DOCKERFILE" > Dockerfile
    docker build -t "$IMAGE_TAG" .
    cd "$REPO_ROOT"
else
    echo "==> Docker image already built, skipping."
fi

echo "==> Building Telegram..."
docker run --rm \
    -u "$(id -u)" \
    -v "$REPO_ROOT:/usr/src/tdesktop" \
    -e CONFIG=Debug \
    "$IMAGE_TAG" \
    /usr/src/tdesktop/Telegram/build/docker/centos_env/build.sh \
    -D CMAKE_CONFIGURATION_TYPES=Debug \
    -D CMAKE_C_FLAGS_DEBUG="-O0" \
    -D CMAKE_CXX_FLAGS_DEBUG="-O0" \
    -D TDESKTOP_API_TEST=ON \
    -D DESKTOP_APP_DISABLE_AUTOUPDATE=ON \
    -D DESKTOP_APP_DISABLE_CRASH_REPORTS=ON

echo ""
echo "==> Done! Binary: out/Debug/Telegram"
