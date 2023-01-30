pushd "$(dirname $BASH_SOURCE)" > /dev/null

__PIC_PROFILE="$(pwd)/$(basename "$BASH_SOURCE")"
export PREFIX="$(pwd)/local"

if [[ ! -f _env_pre.sh ]]; then
    echo "CREATE $(pwd)/_env_pre.sh IN ORDER TO SET ENVIRONMENT VARIABLE CLUSTER_NAME" \
        >&2
else
    . _env_pre.sh
    if [[ "$CLUSTER_NAME" = CRUSHER ]]; then
        . profile/hipcc.profile
        if [[ ! -d "$PREFIX" ]]; then
            python -m pip install virtualenv
            python -m virtualenv "$PREFIX"
        fi
        . "$PREFIX/bin/activate"
    elif [[ "$CLUSTER_NAME" == JUWELS_BOOSTER ]]; then
        export PATH="$PREFIX/bin:$PATH"
        . profile/juwels_booster.profile
    else
        echo "UNKNOWN CLUSTER $CLUSTER_NAME"
    fi
    export PIC_PROFILE="$__PIC_PROFILE"

    for python_version in "$PREFIX/"lib{64,}/python*; do
        if [[ ! -d "$python_version" ]]; then
            continue
        fi
        export PYTHONPATH="$python_version/site-packages:$PYTHONPATH"
    done
    export WORKDIR="$(pwd)/build"
    export LD_LIBRARY_PATH="$PREFIX/lib:$PREFIX/lib64:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$PREFIX:$CMAKE_PREFIX_PATH"
fi

popd
