// This file is compiled as part of the `odin.dll` file. It contains the
// procs that `game.exe` will call, such as:
//
// game_init: Sets up the game state
// game_update: Run once per frame
// game_shutdown: Shuts down game and frees memory
// game_memory: Run just before a hot reload, so game.exe has a pointer to the
//		game's memory.
// game_hot_reloaded: Run after a hot reload so that the `g_mem` global variable
//		can be set to whatever pointer it was in the old DLL.
//
// Note: When compiled as part of the release executable this whole package is imported as a normal
// odin package instead of a DLL.

package game

import "base:runtime"
import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

PIXEL_WINDOW_HEIGHT :: 180
DELTA :: 1.0 / 60

Game_Memory :: struct {
	player_pos:  Vec2,
	some_number: int,
}

g_mem: ^Game_Memory
temp_g_mem: ^Game_Memory
accu: f32 = 0

Input :: struct {
	dir: Vec2,
}

game_camera :: proc() -> rl.Camera2D {
	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	return {zoom = h / PIXEL_WINDOW_HEIGHT, target = g_mem.player_pos, offset = {w / 2, h / 2}}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

input_update :: proc() -> Input {
	input := Input{}

	if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
		input.dir.y -= 1
	}
	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
		input.dir.y += 1
	}
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		input.dir.x -= 1
	}
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		input.dir.x += 1
	}

	input.dir = linalg.normalize0(input.dir)

	return input
}

update :: proc(state: ^Game_Memory, input: Input, dt: f32) {
	g_mem.player_pos += input.dir * dt * 100
	g_mem.some_number += 1
}

draw :: proc(state: ^Game_Memory) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(game_camera())
	rl.DrawRectangleV(state.player_pos, {10, 20}, rl.WHITE)
	rl.DrawRectangleV({20, 20}, {10, 10}, rl.RED)
	rl.DrawRectangleV({-30, -20}, {10, 10}, rl.GREEN)
	rl.EndMode2D()

	rl.BeginMode2D(ui_camera())
	rl.DrawText(
		fmt.ctprintf("some_number: %v\nplayer_pos: %v", state.some_number, state.player_pos),
		5,
		5,
		8,
		rl.WHITE,
	)
	rl.EndMode2D()

	rl.EndDrawing()
}

@(export)
game_update :: proc() -> bool {
	frame_time := rl.GetFrameTime()
	accu += frame_time

	input := input_update()

	for ; accu > DELTA; accu -= DELTA {
		update(g_mem, input, DELTA)
		input = {}
	}
	runtime.mem_copy_non_overlapping(temp_g_mem, g_mem, size_of(Game_Memory))
	update(temp_g_mem, input, accu)

	draw(temp_g_mem)

	return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)
	temp_g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
		some_number = 100,
	}

	game_hot_reloaded(g_mem)
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
	free(temp_g_mem)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}


@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g_mem = (^Game_Memory)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}
