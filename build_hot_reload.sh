#!/usr/bin/env bash

VET="-strict-style -vet-unused -vet-using-stmt -vet-using-param -vet-style -vet-semicolon"

# Run atlas builder, which outputs game/atlas.odin and atlas.png
# Note: You'll have to modify atlas_builder.odin to output atlas.odin to the game subfolder.
# odin run atlas_builder -out:atlas_builder.bin -debug $VET
# if [ ! $? -eq 0 ]; then
#     exit 1
# fi
# chmod +rw game/atlas.odin

# NOTE: this is a recent addition to the Odin compiler, if you don't have this command
# you can change this to the path to the Odin folder that contains vendor, eg: "~/Odin".
ROOT=$(odin root)
if [ ! $? -eq 0 ]; then
    echo "Your Odin compiler does not have the 'odin root' command, please update or hardcode it in the script."
    exit 1
fi

set -eu

# Figure out the mess that is dynamic libraries.
case $(uname) in
"Darwin")
    case $(uname -m) in
    "arm64") LIB_PATH="macos-arm64" ;;
    *)       LIB_PATH="macos" ;;
    esac

    DLL_EXT=".dylib"
    EXTRA_LINKER_FLAGS="-Wl,-rpath $ROOT/vendor/raylib/$LIB_PATH"
    ;;
*)
    DLL_EXT=".so"
    EXTRA_LINKER_FLAGS="'-Wl,-rpath=\$ORIGIN/linux'"

    # Copy the linux libraries into the project automatically.
    if [ ! -d "linux" ]; then
        mkdir linux
        cp -r $ROOT/vendor/raylib/linux/libraylib*.so* linux
    fi
    ;;
esac

# Build the game.
odin build game -extra-linker-flags:"$EXTRA_LINKER_FLAGS" -show-timings -define:RAYLIB_SHARED=true -build-mode:dll -out:game_tmp$DLL_EXT -debug $VET

# Need to use a temp file on Linux because it first writes an empty `game.so`, which the game will load before it is actually fully written.
mv game_tmp$DLL_EXT game$DLL_EXT

# Do not build the game.bin if it is already running.
if pgrep game.bin > /dev/null; then
    exit 1
else
    odin build main_hot_reload -out:game.bin $VET -debug
fi
