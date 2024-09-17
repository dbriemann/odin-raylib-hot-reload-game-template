@echo off

set BUILD_PARAMS=-strict-style -vet-unused -vet-using-stmt -vet-using-param -vet-style -vet-semicolon

odin build main_release -define:RAYLIB_SHARED=false -out:game_release.exe -no-bounds-check -o:speed %BUILD_PARAMS% -subsystem:windows
