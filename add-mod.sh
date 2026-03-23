#!/usr/bin/env bash
set -euo pipefail

# ── Add mod helper for vexmon-pack ──
# Given a Modrinth project URL or slug, fetches the latest compatible version
# and prints the JSON entry ready to paste into the manifest.
#
# Usage:
#   ./add-mod.sh sodium
#   ./add-mod.sh https://modrinth.com/mod/sodium
#   ./add-mod.sh sodium 1.21.1 fabric        (explicit MC version and loader)

cd "$(dirname "$0")"

INPUT="$1"
MC_VERSION="${2:-1.21.1}"
LOADER="${3:-fabric}"

echo "Searching: $INPUT (MC $MC_VERSION, $LOADER)"
echo ""

python3 - "$INPUT" "$MC_VERSION" "$LOADER" << 'PYEOF'
import json, sys, urllib.request, urllib.parse, re

slug = sys.argv[1]

# Extract slug from URL if needed
match = re.search(r'modrinth\.com/(?:mod|shader|resourcepack|plugin)/([^/\s?]+)', slug)
if match:
    slug = match.group(1)
mc_version = sys.argv[2]
loader = sys.argv[3]

params = urllib.parse.urlencode({
    "game_versions": json.dumps([mc_version]),
    "loaders": json.dumps([loader])
})
url = f"https://api.modrinth.com/v2/project/{slug}/version?{params}"

req = urllib.request.Request(url, headers={"User-Agent": "vexmon-pack/1.0"})
with urllib.request.urlopen(req) as resp:
    versions = json.loads(resp.read())

if not versions:
    print(f"No versions found for {slug} on MC {mc_version} with {loader}")
    sys.exit(1)

latest = versions[0]
primary = latest["files"][0]

filename = primary["filename"]
download_url = primary["url"]
sha512 = primary["hashes"].get("sha512", "")
name = latest.get("name", slug)

# Get project name
proj_url = f"https://api.modrinth.com/v2/project/{slug}"
req2 = urllib.request.Request(proj_url, headers={"User-Agent": "vexmon-pack/1.0"})
with urllib.request.urlopen(req2) as resp2:
    project = json.loads(resp2.read())
    name = project.get("title", slug)

print(f"Found: {name} v{latest['version_number']}")
print(f"File:  {filename}")
print("")

# Required mod entry
print("== Mod obbligatoria ==")
entry = {
    "name": name,
    "filename": filename,
    "url": download_url,
    "sha512": sha512
}
print(json.dumps(entry, indent=2, ensure_ascii=False))

print("")

# Optional mod entry
print("== Mod opzionale ==")
entry_opt = {
    "name": name,
    "filename": filename,
    "url": download_url,
    "sha512": sha512,
    "enabledByDefault": True,
    "description": ""
}
print(json.dumps(entry_opt, indent=2, ensure_ascii=False))

PYEOF
