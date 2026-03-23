#!/usr/bin/env bash
set -euo pipefail

# ── Release script for vexmon-pack ──
# Updates SHA512 hashes in both manifests, bumps version, commits, tags, and pushes.
#
# Usage:
#   ./release.sh          (prompts for new version)
#   ./release.sh 1.0.6    (uses provided version)

cd "$(dirname "$0")"

CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('modpack.json'))['modpackVersion'])")
echo "Current version: $CURRENT_VERSION"

if [ $# -ge 1 ]; then
    NEW_VERSION="$1"
else
    read -rp "New version: " NEW_VERSION
fi

if [ -z "$NEW_VERSION" ]; then
    echo "Error: version cannot be empty"
    exit 1
fi

echo ""
echo "Updating to v${NEW_VERSION}..."
echo ""

python3 - "$NEW_VERSION" << 'PYEOF'
import json, hashlib, os, sys

new_version = sys.argv[1]

def compute_sha512(filepath):
    h = hashlib.sha512()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

for manifest_name in ["modpack.json", "modpack-light.json"]:
    with open(manifest_name, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    manifest["modpackVersion"] = new_version
    updated = 0

    if "extraFiles" in manifest:
        for entry in manifest["extraFiles"]:
            url = entry["url"]
            if "/vexmon-pack/main/" not in url:
                continue
            relative = url.split("/vexmon-pack/main/")[1]
            local_path = relative.replace("%2B", "+")
            if not os.path.exists(local_path):
                print(f"  [WARN] Not found: {local_path}")
                continue
            new_hash = compute_sha512(local_path)
            if entry.get("sha512") != new_hash:
                print(f"  [UPDATED] {entry['path']}")
                entry["sha512"] = new_hash
                updated += 1

    with open(manifest_name, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"  {manifest_name}: {updated} hash(es) updated")

PYEOF

echo ""
git add -A
git commit -m "Release v${NEW_VERSION}"
git tag "v${NEW_VERSION}"
git push
git push --tags

echo ""
echo "Released v${NEW_VERSION}"
