# Seaurchin llvm builder image that builds binary seaurchin-llvm library
# Primarily used by the CI
# Arguments:
#  - BASE-IMAGE: jammy-llvm18
#  - BUILD_TYPE: ASSERTIONS_ON, FORCE_ENABLE_STATS
ARG BASE_IMAGE=jammy-llvm18
#FROM seaurchin/buildpack-deps-seaurchin:$BASE_IMAGE
FROM ghcr.io/seahorn/seaurchin-llvm/buildpack-deps-seaurchin:latest
# Assume that docker-build is ran in the top-level SeaHorn directory
COPY . /seaurchin-llvm
# Re-create the build directory that might have been present in the source tree
RUN rm -rf  /seaurchin-llvm/build-rela \
            /seaurchin-llvm/build-rel \ 
            /seaurchin-llvm/debug \ 
            /seaurchin-llvm/release && \
    mkdir /seaurchin-llvm/build-rel
WORKDIR /seaurchin-llvm/build-rel

ARG BUILD_TYPE=ASSERTIONS_ON

# Build configuration
RUN cmake ../llvm -GNinja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -S llvm \
  -GNinja \
  -DCMAKE_CXX_COMPILER=clang++-18 \
  -DCMAKE_C_COMPILER=clang-18 \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
RUN ninja

WORKDIR /seaurchin-llvm