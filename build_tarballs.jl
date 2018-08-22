# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "ASLBuilder"
version = v"3.1.0"

# Collection of sources required to build ASLBuilder
sources = [
    "https://github.com/ampl/mp/archive/3.1.0.tar.gz" =>
    "587c1a88f4c8f57bef95b58a8586956145417c8039f59b1758365ccc5a309ae9",

    "https://github.com/staticfloat/mp-extra/archive/v3.1.0-2.tar.gz" =>
    "2f227175437f73d9237d3502aea2b4355b136e29054267ec0678a19b91e9236e",

]

# Bash recipe for building across all platforms
script = raw"""
# Use staticfloat's cross-compile trick for ASL https://github.com/ampl/mp/issues/115

cd $WORKSPACE/srcdir/mp-3.1.0
rm -rf thirdparty/benchmark
patch -p1 < $WORKSPACE/srcdir/mp-extra-3.1.0-2/no_benchmark.patch

# Build ASL

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix  -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain       -DRUN_HAVE_STD_REGEX=0       -DRUN_HAVE_STEADY_CLOCK=0       ../

# Copy over pregenerated files after building arithchk, so as to fake out cmake,
# because cmake will delete our arith.h

## If this fails it is ok, we just want to prevend cmake deleting arith.h
set +e
make arith-h VERBOSE=1
set -e

mkdir -p src/asl
cp -v $WORKSPACE/srcdir/mp-extra-3.1.0-2/expr-info.cc ../src/expr-info.cc
cp -v $WORKSPACE/srcdir/mp-extra-3.1.0-2/arith.h.${target} src/asl/arith.h

# Build and install ASL

make -j${nproc} VERBOSE=1
make install VERBOSE=1

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

