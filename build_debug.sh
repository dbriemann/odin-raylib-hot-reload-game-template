#!/usr/bin/env bash

# Run atlas builder, which outputs game/atlas.odin and atlas.png
# Note: You'll have to modify atlas_builder.odin to output atlas.odin to the game subfolder.
# odin run atlas_builder -out:atlas_builder.bin -debug $VET
# if [ ! $? -eq 0 ]; then
#    exit 1
# fi
# chmod +rw game/atlas.odin

odin build main_release -out:game_debug.bin -no-bounds-check -debug
