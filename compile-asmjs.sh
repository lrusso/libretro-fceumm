#!/bin/bash

# Builds the FCEUmm libretro core as asm.js (pure JavaScript, no WebAssembly) for the
# browser. The Emscripten SDK has to be set up already (emsdk_env), this script doesn't
# install or update it. The output is fceumm_libretro_emscripten.js.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOBS="$(sysctl -n hw.ncpu 2> /dev/null || nproc)"

if ! command -v emcc > /dev/null; then
    echo "emcc not found, set up the Emscripten SDK environment first (emsdk_env)"
    exit 1
fi

echo "Using $(emcc --version | head -n1)"

cd "${SCRIPT_DIR}"

# A clean build, so the objects and the output always come from these settings.
make -f Makefile.libretro platform=emscripten clean

# platform=emscripten already builds asm.js (WASM=0), and ENVIRONMENT=web leaves out
# the code that only runs in Node. It goes in as an environment variable because the
# makefile appends its own flags to LDFLAGS, while a command line LDFLAGS would replace
# them.
LDFLAGS="-s ENVIRONMENT=web" make -f Makefile.libretro platform=emscripten -j"${JOBS}"

echo "Done: ${SCRIPT_DIR}/fceumm_libretro_emscripten.js"
