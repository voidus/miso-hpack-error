#!/bin/bash
set -e
files=( Main.hs app.cabal cabal.config default.nix )

rm -fr ${files[*]} package.yaml miso hpack-convert

git clone git://github.com/dmjio/miso
( cd miso; git checkout 1114ba461605cef11ef4e1a96b5adfc4b4c9af18)
for F in ${files[*]}; do cp miso/sample-app/$F .; done
rm -rf miso

USE_PRECALCULATED_PACKAGE_YAML=true

if $USE_PRECALCULATED_PACKAGE_YAML; then
    cat > package.yaml <<HERE
name: app
version: '0.1.0.0'
synopsis: First miso app
category: Web
license: PublicDomain
dependencies:
- base
- miso
executables:
  app:
      main: Main.hs
HERE

else
    git clone git://github.com/yamadapc/hpack-convert
    (
        cd hpack-convert
        git checkout v1.0.1
        sed -i '' 33d package.yaml # The package.yml contains an empty dependencies: line, which modern stack doesn't like
        stack build
        `stack path --dist-dir`/build/hpack-convert/hpack-convert ..
    )
    rm app.cabal
    rm -rf hpack-convert
    sed -i '' 's/UnspecifiedLicense/PublicDomain/' package.yaml
fi
