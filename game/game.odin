// This file is compiled as part of the `odin.dll` file. It contains the
// procs that `game_hot_reload.exe` will call, such as:
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

import "../utils/tween"

PIXEL_WINDOW_HEIGHT :: 200
DELTA :: 1.0 / 60

Game_State :: struct {
	tick_count: f64,
	zoom_tween: tween.Tween,
	zoom:       f32,
	camera:     rl.Camera2D,
	fixpoint:   rl.Vector2,
	player_pos: rl.Vector2,
}

Game_Memory :: struct {
	game_state:   Game_State,
	render_state: Game_State,
	accu:         f32,
	tick_input:   Input,
}

g_mem: ^Game_Memory

set_game_camera :: proc(state: ^Game_State, input: Input) {
	mouse_world_before := rl.GetScreenToWorld2D(input.cursor, state.camera)

	w := f32(rl.GetScreenWidth())
	h := f32(rl.GetScreenHeight())

	screen_center := rl.Vector2{w / 2, h / 2}

	state.camera = {
		zoom   = state.zoom,
		target = state.fixpoint,
		offset = screen_center,
	}

	mouse_world_after := rl.GetScreenToWorld2D(input.cursor, state.camera)

	translated := mouse_world_after - mouse_world_before
	state.camera.target -= translated
	state.fixpoint -= translated
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = f32(rl.GetScreenHeight()) / PIXEL_WINDOW_HEIGHT}
}

input_update :: proc() {
	frame_input: Input
	frame_input.cursor = rl.GetMousePosition()
	frame_input.wheel = rl.GetMouseWheelMove()
	frame_input.actions[.Left] = Input__flags_from_keys(.A, .LEFT)
	frame_input.actions[.Right] = Input__flags_from_keys(.D, .RIGHT)
	frame_input.actions[.Up] = Input__flags_from_keys(.W, .UP)
	frame_input.actions[.Down] = Input__flags_from_keys(.S, .DOWN)

	g_mem.tick_input.cursor = frame_input.cursor
	g_mem.tick_input.wheel = frame_input.wheel
	for flags, action in frame_input.actions {
		g_mem.tick_input.actions[action] += flags
	}
}

draw :: proc(state: ^Game_State) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(state.camera)
	rl.DrawRectangleV(state.player_pos, {10, 20}, rl.WHITE)
	rl.DrawRectangleV({20, 20}, {10, 10}, rl.RED)
	rl.DrawRectangleV({-30, -20}, {10, 10}, rl.GREEN)
	rl.EndMode2D()

	rl.BeginMode2D(ui_camera())
	rl.DrawText(
		fmt.ctprintf("tick_count: %v\nplayer_pos: %v", int(state.tick_count), state.player_pos),
		5,
		5,
		8,
		rl.WHITE,
	)
	rl.EndMode2D()

	rl.EndDrawing()
}

tick :: proc(state: ^Game_State, input: Input, dt: f32) {
	state.tick_count += 1

	move_dir: rl.Vector2
	if .Down in input.actions[.Left] do move_dir.x -= 1
	if .Down in input.actions[.Right] do move_dir.x += 1
	if .Down in input.actions[.Up] do move_dir.y -= 1
	if .Down in input.actions[.Down] do move_dir.y += 1

	move_dir = linalg.normalize(move_dir)
	moving := move_dir != 0
	if moving {
		state.player_pos += move_dir * dt * 100
	}

	if input.wheel != 0 {
		target := state.zoom_tween.end
		if input.wheel < 0 {
			target /= 1.75
		} else if input.wheel > 0 {
			target *= 1.75
		}
		if target < 1 {
			target = 1
		}
		state.zoom_tween = tween.new_Tween(state.zoom, target, 0.25, tween.ease_linear)
	}

	current, _ := tween.Tween__update(&state.zoom_tween, dt)
	state.zoom = current

	set_game_camera(state, input)
}

@(export)
game_update :: proc() -> bool {
	frame_time := rl.GetFrameTime()
	g_mem.accu += frame_time

	input_update()
	// fmt.println()

	any_tick := g_mem.accu > DELTA
	defer if any_tick do g_mem.tick_input = {}

	for ; g_mem.accu > DELTA; g_mem.accu -= DELTA {
		// fmt.println("update tick")
		tick(&g_mem.game_state, g_mem.tick_input, DELTA)
		Input__clear_volatile(&g_mem.tick_input)
	}
	// fmt.println(g_mem.tick_input.wheel)
	runtime.mem_copy_non_overlapping(&g_mem.render_state, &g_mem.game_state, size_of(Game_State))
	tick(&g_mem.render_state, g_mem.tick_input, g_mem.accu)

	draw(&g_mem.render_state)

	return !rl.WindowShouldClose()
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1200, 800, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
		game_state = Game_State {
			zoom = 1.0,
			zoom_tween = tween.new_Tween(1, 1, 0.25, tween.ease_in_cubic),
			camera = rl.Camera2D {
				zoom = 1.0,
				target = {0, 0},
				offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			},
		},
		render_state = Game_State{},
	}

	game_hot_reloaded(g_mem)
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
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
