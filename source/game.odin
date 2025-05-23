/*
This file is the starting point of your game.

Some important procedures are:
- game_init_window: Opens the window
- game_init: Sets up the game state
- game_update: Run once per frame
- game_should_close: For stopping your game when close button is pressed
- game_shutdown: Shuts down game and frees memory
- game_shutdown_window: Closes window

The procs above are used regardless if you compile using the `build_release`
script or the `build_hot_reload` script. However, in the hot reload case, the
contents of this file is compiled as part of `build/hot_reload/game.dll` (or
.dylib/.so on mac/linux). In the hot reload cases some other procedures are
also used in order to facilitate the hot reload functionality:

- game_memory: Run just before a hot reload. That way game_hot_reload.exe has a
	pointer to the game's memory that it can hand to the new game DLL.
- game_hot_reloaded: Run after a hot reload so that the `g` global
	variable can be set to whatever pointer it was in the old DLL.

NOTE: When compiled as part of `build_release`, `build_debug` or `build_web`
then this whole package is just treated as a normal Odin package. No DLL is
created.
*/

package game

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

import "tween"

DELTA :: 1.0 / 60

Game_State :: struct {
	// Flags
	running:     bool,

	// UI state data
	zoom_tween:  tween.Tween,
	zoom:        f32,
	dragging:    bool,
	drag_origin: [2]f32,
	drag_target: [2]f32,
	drag_dir:    [2]f32,
	fixpoint:    [2]f32,
	camera:      rl.Camera2D,

	// Actual game state data
	tick_count:  f64,
	player_pos:  [2]f32,
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

	if state.dragging {
		state.camera.target += state.drag_dir
	}
}

ui_camera :: proc() -> rl.Camera2D {
	return {zoom = 1}
}

input_update :: proc() {
	frame_input: Input
	frame_input.cursor = rl.GetMousePosition()
	frame_input.wheel = rl.GetMouseWheelMove()
	frame_input.actions[.Left] = Input__flags_from_keys(.A, .LEFT)
	frame_input.actions[.Right] = Input__flags_from_keys(.D, .RIGHT)
	frame_input.actions[.Up] = Input__flags_from_keys(.W, .UP)
	frame_input.actions[.Down] = Input__flags_from_keys(.S, .DOWN)
	frame_input.actions[.Esc] = Input__flags_from_keys(.ESCAPE)
	frame_input.actions[.Mouse_Right] = Input__flags_from_mouse_button(.RIGHT)
	frame_input.actions[.Mouse_Left] = Input__flags_from_mouse_button(.LEFT)

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
	rl.SetTextLineSpacing(24)
	rl.DrawText(fmt.ctprintf("tick_count: %v\n", int(state.tick_count)), 5, 5, 24, rl.WHITE)
	if state.dragging {
		rl.DrawLineV(state.drag_origin, state.drag_target, rl.WHITE)
		rl.DrawCircleV(state.drag_origin, 4, rl.GREEN)
		rl.DrawCircleV(state.drag_target, 4, rl.RED)
	}
	rl.EndMode2D()

	rl.EndDrawing()
}

tick :: proc(state: ^Game_State, input: Input, dt: f32) {
	// Update input & ui data.
	if .Down in input.actions[.Esc] do state.running = false
	move_dir: rl.Vector2
	if .Down in input.actions[.Left] do move_dir.x -= 1
	if .Down in input.actions[.Right] do move_dir.x += 1
	if .Down in input.actions[.Up] do move_dir.y -= 1
	if .Down in input.actions[.Down] do move_dir.y += 1

	move_dir = linalg.normalize(move_dir)

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

	if .Down in input.actions[.Mouse_Right] {
		if !state.dragging {
			// Start dragging.
			state.dragging = true
			// state.drag_origin = input.cursor
			state.drag_origin = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
		} else {
			// Drag (move).
			state.drag_target = input.cursor
			state.drag_dir = state.drag_target - state.drag_origin
			state.drag_dir *= 2 * dt / math.sqrt(state.zoom)
		}
	}
	if .Released in input.actions[.Mouse_Right] {
		// Stop dragging.
		state.dragging = false
	}
	current, _ := tween.Tween__update(&state.zoom_tween, dt)
	state.zoom = current

	set_game_camera(state, input)

	// Update game data.
	state.tick_count += 1

	moving := move_dir != 0
	if moving {
		state.player_pos += move_dir * dt * 100
	}
}

///////////////////


@(export)
game_update :: proc() {
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

	// Everything on tracking allocator is valid until end-of-frame.
	free_all(context.temp_allocator)
}

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 800, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
	rl.SetExitKey(nil)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
		game_state = Game_State {
            running = true,
			zoom = 1.0,
			zoom_tween = tween.new_Tween(1, 1, 0.25, tween.ease_in_cubic),
			camera = rl.Camera2D {
				zoom = 1.0,
				target = {0, 0},
				offset = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
			},

            // You can put textures, sounds and music in the `assets` folder. Those
            // files will be part any release or web build.
            // player_texture = rl.LoadTexture("assets/round_cat.png"),
		},
		render_state = Game_State{},
	}

	game_hot_reloaded(g_mem)
}

@(export)
game_should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			return false
		}
	}

	return g_mem.game_state.running
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

	// Here you can also set your own global variables. A good idea is to make
	// your global variables into pointers that point to something inside `g`.
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.F5)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.F6)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
game_parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(i32(w), i32(h))
}
