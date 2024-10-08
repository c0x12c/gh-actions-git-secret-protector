#!/bin/bash

SEMTAG='./tools/semtag'
ACTION=${1:-patch}

git fetch origin --tags

RELEASE_VERSION="$($SEMTAG final -s $ACTION -o)"

echo "Next release version: $RELEASE_VERSION"

if test -f "package.json"; then
  npm version "$RELEASE_VERSION" -no-git-tag-version
  git commit -m "chore: bump version to $RELEASE_VERSION" -a
  git push origin master
fi

$SEMTAG final -s $ACTION -v "$RELEASE_VERSION"

STRIPPED_PATCH_VERSION="${RELEASE_VERSION%.*}"

git tag -f "$STRIPPED_PATCH_VERSION" "$RELEASE_VERSION"
git push origin "$STRIPPED_PATCH_VERSION" --force

STRIPPED_MINOR_VERSION=${RELEASE_VERSION%%.*}

git tag -f "$STRIPPED_MINOR_VERSION" "$RELEASE_VERSION"
git push origin "$STRIPPED_MINOR_VERSION" --force
