pushd "$(dirname $BASH_SOURCE)" > /dev/null

__PIC_PROFILE="$(pwd)/$(basename "$BASH_SOURCE")"
export PREFIX="$(pwd)/local"

if [[ ! -f env_pre.sh ]]; then
    echo "CREATE $(pwd)/env_pre.sh IN ORDER TO SET ENVIRONMENT VARIABLE CLUSTER_NAME" \
        >&2
else
    . env_pre.sh
    if [[ "$CLUSTER_NAME" = CRUSHER ]]; then
        . profile/hipcc.profile
    elif [[ "$CLUSTER_NAME" == JUWELS_BOOSTER ]]; then
        . profile/juwels_booster.profile
    fi
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
fi

popd
