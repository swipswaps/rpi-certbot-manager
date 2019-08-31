#!/usr/bin/env bash

# File is a modified copy from https://github.com/michaelsauter/crane/blob/master/release.sh

set -eux

version=$1

if [ -z "$version"  ]; then
  echo "No version passed! Example usage: ./release.sh 1.0.0"
    exit 1
fi

echo "Update version..."
old_version=$(grep -o "[0-9]*\.[0-9]*\.[0-9]*" VERSION)
sed -i.bak 's/Version = "'$old_version'"/Version = "'$version'"/' VERSION
rm VERSION.bak
sed -i.bak 's/'$old_version'/'$version'/' README.md
rm README.md.bak

echo "Mark version as released in changelog..."
today=$(date +'%Y-%m-%d')
sed -i.bak 's/Unreleased/Unreleased\
\
## '$version' ('$today')/' CHANGELOG.md
rm CHANGELOG.md.bak

echo "Update contributors..."
git contributors | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' > CONTRIBUTORS

echo "Update repository..."
git add VERSION README.md CHANGELOG.md
git commit -m "Bump version to ${version}"
git tag --message="v$version" --force "v$version"
git tag --message="latest" --force latest

echo "v$version tagged."
echo "Now, run 'git push origin master && git push --tags --force' and publish the release on GitHub."
