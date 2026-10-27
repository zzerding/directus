#!/bin/sh
# Smoke-check a Directus image (docker) or a running instance (url).
# usage: smoke.sh --image IMG [--port P] | --url URL   (curl required; docker for --image)
set -eu
PORT=18055 IMAGE= URL=
while [ $# -gt 0 ]; do
  case $1 in
    --image) IMAGE=$2; shift 2 ;;
    --url)   URL=$2;   shift 2 ;;
    --port)  PORT=$2;  shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -z "$IMAGE" ] && [ -z "$URL" ] && { echo "need --image or --url" >&2; exit 2; }

CONTAINER=
if [ -n "$IMAGE" ]; then
  URL="http://127.0.0.1:$PORT"
  CONTAINER=$(docker run -d --rm -p "$PORT:8055" \
    -e KEY=smoke-key -e SECRET=smoke-secret -e PUBLIC_URL="$URL" "$IMAGE")
  trap 'docker logs --tail 60 "$CONTAINER" >&2 2>/dev/null; docker rm -f "$CONTAINER" >/dev/null 2>&1' EXIT
fi

try=0
until curl -fsS -o /dev/null "$URL/server/health" 2>/dev/null; do
  try=$((try + 1))
  [ "$try" -gt 90 ] && { echo "FAIL: $URL/server/health never came up" >&2; exit 1; }
  sleep 2
done
curl -fsS -o /dev/null "$URL/server/health"
curl -fsS -o /dev/null "$URL/server/ping"
curl -fsS "$URL/" | grep -qi 'id="app"'
echo "smoke OK: $URL"
