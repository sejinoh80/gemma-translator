#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

cd "$(dirname "$0")"

# The litert-lm native library links against the Vulkan loader
# (libvulkan.so.1) even for CPU inference, so it must be present for the
# litert-lm CLI to start at all.
if ! ldconfig -p | grep -q 'libvulkan\.so\.1'; then
    echo "Installing Vulkan loader (libvulkan1) required by litert-lm..."
    sudo apt-get update
    sudo apt-get install -y libvulkan1
fi

# start.sh runs the Vite frontend via npm, which requires Node 18+ (Vite 5).
# Debian/Raspberry Pi OS/Ubuntu ship Node 18+ via apt, which satisfies this.
if ! command -v npm &> /dev/null; then
    echo "Installing Node.js/npm required by the frontend..."
    sudo apt-get update
    sudo apt-get install -y nodejs npm
fi
NODE_MAJOR="$(node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -lt 18 ] 2>/dev/null; then
    echo "Warning: Node.js v${NODE_MAJOR} detected, but v18+ is required by the frontend."
fi

echo "Creating virtual environment..."
python3 -m venv venv

echo "Activating virtual environment..."
source venv/bin/activate

echo "Installing requirements..."
#pip install --require-hashes --extra-index-url https://pypi.org/simple/ -r backend/requirements.txt
pip install -r backend/requirements.txt

echo "========================================="
echo "Setup complete!"
echo "Run ./download_model.sh to download the model."
echo "Run ./start.sh to start the servers."
echo "========================================="
