#!/bin/bash
set -e

export FC=gfortran CC=gcc
# rm -rf build
# Removing link args fixes the "attempted static link of dynamic library" error
meson setup build -Dfortran_link_args=
ninja -C build