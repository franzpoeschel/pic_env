pushd "$(dirname $BASH_SOURCE)" > /dev/null

__PIC_PROFILE="$(pwd)/$(basename "$BASH_SOURCE")"
export PREFIX="$(pwd)/local"

. profile/hipcc.profile
export PIC_PROFILE="$__PIC_PROFILE"

if [[ ! -d "$PREFIX" ]]; then
    python -m pip install virtualenv
    python -m virtualenv "$PREFIX"
fi
. "$PREFIX/bin/activate"
export WORKDIR="$(pwd)/build"
export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64:$LD_LIBRARY_PATH"
# export PATH="$PREFIX/bin:$PATH"
export CMAKE_PREFIX_PATH="$PREFIX:$CMAKE_PREFIX_PATH"

popd
