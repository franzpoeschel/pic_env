#!/usr/bin/env bash

pushd "$(dirname $BASH_SOURCE)" > /dev/null

chmod -R a+r "$(pwd)"
chmod -R +t "$(pwd)"
find local -executable -a -type f | xargs chmod a+x

popd > /dev/null