#!/usr/bin/env bash
set -euo pipefail

PROFILE="${DSH_PROFILE:-desktop}"
REPO="komeiji-cobalt/dsh-isaac-widget"

if ! command -v dsh >/dev/null 2>&1; then
  echo "dsh CLI not found. Install DeepSeek Harness first, or add its CLI to PATH." >&2
  exit 1
fi

SPEC="github:${REPO}"
if [[ "${1:-}" == "--local" ]]; then
  SPEC="link:$(cd "$(dirname "$0")" && pwd)"
fi

echo
echo "dsh-isaac-widget"
echo "  profile: ${PROFILE}"
echo "  spec:    ${SPEC}"
echo

dsh plugin --profile "${PROFILE}" add "${SPEC}"

echo
echo "Installed."
if [[ "${PROFILE}" == "desktop" ]]; then
  echo "Fully quit DeepSeek Harness (including the tray icon), then reopen it."
else
  echo "Restart the dsh web server, then refresh the browser."
fi
echo "Click the Isaac at the bottom-right for the spider bubble + HurtGrunt."
