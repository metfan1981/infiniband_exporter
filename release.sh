#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN is not set."
  exit 1
fi

version=$(cat VERSION)
echo "==> VERSION file says: $version (all binaries and tarballs will use this)"

read -rp "Create and push git tag v${version}? [y/N]: " do_tag
if [[ "${do_tag,,}" == "y" ]]; then
  if git rev-parse "v${version}" &>/dev/null; then
    echo "Tag v${version} already exists, skipping."
  else
    git tag "v${version}"
    git push origin "v${version}"
    echo "==> Tagged and pushed v${version}"
  fi
fi

echo "==> Crossbuilding all platforms"
promu crossbuild

echo "==> Creating tarballs"
promu crossbuild tarballs

echo "==> Uploading release to GitHub"
promu release .tarballs

echo "==> Done: $version released"
