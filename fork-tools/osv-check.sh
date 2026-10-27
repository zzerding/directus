#!/bin/sh
# OSV tripwire for the fork base. Exit 1 = vulns newly affecting the given version.
# usage: osv-check.sh [VERSION] [--all] [--update]   (curl + jq required)
set -eu
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
KNOWN="$DIR/.known-osv-ids"
VERSION=11.17.4 ALL=0 UPDATE=0
for a in "$@"; do
  case $a in
    --all) ALL=1 ;;
    --update) UPDATE=1 ;;
    *) VERSION=$a ;;
  esac
done
if [ "$ALL" = 1 ]; then
  BODY='{"package":{"name":"directus","ecosystem":"npm"}}'
else
  BODY=$(printf '{"package":{"name":"directus","ecosystem":"npm"},"version":"%s"}' "$VERSION")
fi
NOW=$(mktemp)
trap 'rm -f "$NOW"' EXIT
curl -fsS -X POST https://api.osv.dev/v1/query -d "$BODY" | jq -r '.vulns[]?.id' | sort -u > "$NOW"
new=$(comm -13 "$KNOWN" "$NOW")
gone=$(comm -23 "$KNOWN" "$NOW")
[ -n "$new" ] && { echo "NEW vulns affecting directus $VERSION:"; echo "$new"; }
[ -n "$gone" ] && { echo "no longer affecting (informational):"; echo "$gone"; }
[ -z "$new" ] && echo "osv-check OK: no new vulns for $VERSION"
[ "$UPDATE" = 1 ] && { cp "$NOW" "$KNOWN"; echo "baseline updated: $KNOWN"; }
[ -z "$new" ]
