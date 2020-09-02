set -x

function build_cmake {
    build_simple cmake 3.7.2 https://cmake.org/files/v3.7/
}

function pre_build {
    if [ -z "$IS_OSX" ]; then
        build_cmake
        build_hdf5

        # Add workaround for auditwheel bug:
        # https://github.com/pypa/auditwheel/issues/29
        local bad_lib="/usr/local/lib/libhdf5.so"
        if [ -z "$(readelf --dynamic $bad_lib | grep RUNPATH)" ]; then
            echo "Patching $bad_lib"
            patchelf --set-rpath $(dirname $bad_lib) $bad_lib
        fi
    else
        brew list cmake || brew install cmake
        brew list hdf5 || brew install hdf5
    fi
}

function run_tests {
    python --version
    python -c 'import sys; import morphio; print(morphio.version)'
}
