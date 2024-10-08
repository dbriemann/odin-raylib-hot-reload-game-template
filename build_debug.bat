@echo off

rem Run atlas builder, which outputs game/atlas.odin and atlas.png
rem Note: You'll have to modify atlas_builder.odin to output atlas.odin to the game subfolder.
rem odin run atlas_builder -debug
rem IF %ERRORLEVEL% NEQ 0 exit /b 1

set BUILD_PARAMS=-strict-style -vet-using-stmt -vet-using-param -vet-style -vet-semicolon -debug

odin build main_release -define:RAYLIB_SHARED=false -out:game_debug.exe -subsystem:windows %BUILD_PARAMS%
