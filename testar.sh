#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker não foi encontrado. Instale o Docker Desktop e habilite a integração com esta distribuição WSL." >&2
  exit 127
fi

docker run --rm --ipc=host \
  -v "$PWD:/work" \
  -v web_03_cartao_perfil_node_modules:/work/node_modules \
  -w /work \
  mcr.microsoft.com/playwright:v1.64.1-noble \
  sh -lc '
    lock_hash=$(sha256sum package-lock.json | cut -d" " -f1)
    if [ ! -x node_modules/.bin/playwright ] || [ ! -f node_modules/.package-lock-sha ] || [ "$(cat node_modules/.package-lock-sha)" != "$lock_hash" ]; then
      npm ci
      printf "%s\n" "$lock_hash" > node_modules/.package-lock-sha
    fi
    if [ "$#" -gt 0 ]; then
      exec npx playwright test tests/avaliacao.spec.js --grep "$1"
    fi
    exec npx playwright test
  ' sh "$@"
