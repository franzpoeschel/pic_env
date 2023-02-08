#!/bin/bash
# call with environment variables WORKDIR, PREFIX
set -x

if [[ -z "$NPROC" ]]; then
    export NPROC=$(nproc)
fi

install_adios2() {
    # install_bzip2
    cd "$WORKDIR"
    if [ ! -d ADIOS2 ]; then
        git clone https://github.com/ornladios/ADIOS2
        cd ADIOS2
    else
        cd ADIOS2
        git fetch --all
    fi
    git checkout 9516443483e76c2edc9ec9b0538c5eac031ccf18
    local build_python_bindings=OFF
    mkdir -p build
    cd build
    cmake .. -DADIOS2_BUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" -DADIOS2_USE_Fortran=OFF \
        -DADIOS2_USE_BZip2=AUTO -DADIOS2_USE_PNG=OFF \
        -DADIOS2_USE_Python="$build_python_bindings"
    make -j $NPROC install
    cd ../..
}

install_openPMD() {
    cd "$WORKDIR"
    if [ ! -d openPMD-api ]; then
        git clone https://github.com/franzpoeschel/openPMD-api
    fi
    cd openPMD-api
    git fetch --all
    git checkout 9d6d78e9474b7507541b126aa834f907b8581ef8
    if [ ! -d build ]; then
        mkdir build
        cd build
        cmake .. \
            -DBUILD_EXAMPLES=ON -DBUILD_TESTING=OFF \
            -DopenPMD_USE_PYTHON=ON \
            -DPython_EXECUTABLE=`which python` \
            -DCMAKE_INSTALL_PREFIX="$PREFIX"
    else
        cd build
    fi
    make -j $NPROC install
    cd ../..
}

build_PIC() {
    cd "$WORKDIR"
    echo "Building PIC"
    if [ ! -d picongpu ]; then
        git clone https://github.com/franzpoeschel/picongpu
    fi
    cd picongpu
    git checkout pic_env
    git fetch --all
    git reset --hard origin/pic_env
    cd ..
    local sourcedir="$(pwd)/picongpu"
    PATH="$sourcedir/bin:$PATH"
    if [ ! -d pic_build ]; then
        pic-create \
            "$sourcedir/share/picongpu/examples/KelvinHelmholtz" \
            pic_build
    fi
    cd pic_build
    MAKEFLAGS="-j$NPROC" pic-build
    mkdir -p "$PREFIX/bin"
    rsync -O --no-perms -avuP bin/* "$PREFIX/bin/"
    cd ..
}

########
# Main #
########

if [ ! -d "$WORKDIR" ]; then
    mkdir "$WORKDIR"
fi

cd "$WORKDIR"

if [[ "$CLUSTER_NAME" = CRUSHER ]]; then
    CRAY_ACCEL_TARGET=none pip install --ignore-installed numpy mpi4py
elif [[ "$CLUSTER_NAME" = JUWELS_BOOSTER ]]; then
    true # noop
else
    echo "UNKNOWN CLUSTER $CLUSTER_NAME" >&2
    exit
fi
install_adios2
install_openPMD
build_PIC
