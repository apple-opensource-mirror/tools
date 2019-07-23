#!/bin/zsh
set -eo pipefail

cd $1
rm -rf repo
mkdir repo
git -C repo init

for tarball in $(ls *.tar.gz | sort -V); do
  echo $tarball
  rm -rf repo/* || true
  tar --strip-components=1 -C repo -x -f $tarball
  git -C repo add .
  GIT_COMMITTER_NAME="Apple" GIT_COMMITTER_EMAIL="opensource@apple.com" GIT_COMMITTER_DATE="$(stat -f '%Sm' $tarball)" git -C repo commit -m ${tarball:r:r} --date="$(stat -f '%Sm' $tarball)" --author="Apple <opensource@apple.com>" --allow-empty
done

(
  cd repo
  hub create -d "Mirror of Apple's open source release of ${PWD:h:t}" -h "https://opensource.apple.com/tarballs/${PWD:h:t}" "apple-opensource-mirror/${PWD:h:t}"
)
git -C repo push -u origin master -f
