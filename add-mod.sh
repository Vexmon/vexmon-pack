#!/usr/bin/env bash
set -euo pipefail

# ── Add mod helper for vexmon-pack ──
# Given a Modrinth version URL, fetches mod info and prints JSON entries
# ready to paste into the manifest.
#
# Usage:
#   ./add-mod.sh https://modrinth.com/mod/fabric-api/version/0.144.0+26.1

cd "$(dirname "$0")"

INPUT="$1"

python3 - "$INPUT" << 'PYEOF'
import json, sys, urllib.request, urllib.parse, re

input_url = sys.argv[1]

# Extract slug and version from URL: .../mod/{slug}/version/{version}
match = re.search(r'modrinth\.com/(?:mod|shader|resourcepack|plugin)/([^/]+)/version/(.+)', input_url)
if not match:
    print(f"URL non valido. Formato: https://modrinth.com/mod/<slug>/version/<version>")
    sys.exit(1)

slug = match.group(1)
version_number = urllib.parse.unquote(match.group(2)).strip().rstrip("/")

# Fetch all versions for the project
api_url = f"https://api.modrinth.com/v2/project/{slug}/version"
req = urllib.request.Request(api_url, headers={"User-Agent": "vexmon-pack/1.0"})
with urllib.request.urlopen(req) as resp:
    versions = json.loads(resp.read())

# Find the matching version
target = None
for v in versions:
    if v["version_number"] == version_number:
        target = v
        break

if not target:
    print(f"Versione '{version_number}' non trovata per {slug}")
    print(f"Versioni disponibili: {', '.join(v['version_number'] for v in versions[:10])}")
    sys.exit(1)

primary = target["files"][0]
filename = primary["filename"]
download_url = primary["url"]
sha512 = primary["hashes"].get("sha512", "")

# Get project name
proj_url = f"https://api.modrinth.com/v2/project/{slug}"
req2 = urllib.request.Request(proj_url, headers={"User-Agent": "vexmon-pack/1.0"})
with urllib.request.urlopen(req2) as resp2:
    project = json.loads(resp2.read())
    name = project.get("title", slug)

print(f"Found: {name} v{target['version_number']}")
print(f"File:  {filename}")
print("")

print("== Mod obbligatoria ==")
entry = {
    "name": name,
    "filename": filename,
    "url": download_url,
    "sha512": sha512
}
print(json.dumps(entry, indent=2, ensure_ascii=False))

print("")

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
