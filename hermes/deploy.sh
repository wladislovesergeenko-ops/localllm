#!/bin/bash
# Deploy Hermes Agent on a fresh Linux server
set -e

cd "$(dirname "$0")"

echo "=== Hermes Deploy ==="

# 1. Clone hermes-agent if not present
if [ ! -d "hermes-agent" ]; then
    echo "Cloning hermes-agent..."
    git clone https://github.com/NousResearch/hermes-agent.git hermes-agent
fi

# 2. Apply patches
echo "Applying patches..."

# Patch: add git to Dockerfile (npm needs it)
sed -i 's/build-essential nodejs npm python3 ripgrep ffmpeg gcc python3-dev libffi-dev procps/build-essential nodejs npm python3 ripgrep ffmpeg gcc python3-dev libffi-dev procps git/' hermes-agent/Dockerfile

# Patch: skip text when voice is sent
sed -i 's/# Send the text portion\n\s*if text_content:/# Send the text portion (skip if voice was already sent)\n                if text_content and not _tts_path:/' hermes-agent/gateway/platforms/base.py 2>/dev/null || \
python3 -c "
import re
with open('hermes-agent/gateway/platforms/base.py', 'r') as f:
    content = f.read()
content = content.replace(
    '# Send the text portion\n                if text_content:',
    '# Send the text portion (skip if voice was already sent)\n                if text_content and not _tts_path:'
)
with open('hermes-agent/gateway/platforms/base.py', 'w') as f:
    f.write(content)
print('base.py patched')
"

# 3. Check .env
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo ""
    echo ">>> Created .env from template. Fill in your keys:"
    echo "    OPENAI_API_KEY, OPENROUTER_API_KEY, TELEGRAM_BOT_TOKEN"
    echo "    Then re-run: docker compose up -d --build"
    exit 1
fi

# 4. Build and run
echo "Building and starting Hermes (first build takes 5-10 min)..."
docker compose up -d --build

echo ""
echo "=== Done! ==="
echo "Logs:    docker compose logs -f"
echo "Stop:    docker compose down"
