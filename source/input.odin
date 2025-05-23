package game

import rl "vendor:raylib"

Input :: struct {
	cursor:  rl.Vector2,
	wheel:   f32,
	actions: [Input_Action]bit_set[Input_Flag],
}

Input_Action :: enum u8 {
	Left,
	Right,
	Up,
	Down,
    Esc,
	Mouse_Left,
	Mouse_Right,
}

Input_Flag :: enum u8 {
	Down,
	Pressed,
	Released,
}

Input__flags_from_keys :: proc(keys: ..rl.KeyboardKey) -> (flags: bit_set[Input_Flag]) {
	for key in keys {
		if rl.IsKeyDown(key) do flags += {.Down}
		if rl.IsKeyPressed(key) do flags += {.Pressed}
		if rl.IsKeyReleased(key) do flags += {.Released}
	}
	return
}

Input__flags_from_mouse_button :: proc(mb: rl.MouseButton) -> (flags: bit_set[Input_Flag]) {
	if rl.IsMouseButtonDown(mb) do flags += {.Down}
	if rl.IsMouseButtonPressed(mb) do flags += {.Pressed}
	if rl.IsMouseButtonReleased(mb) do flags += {.Released}
	return
}

Input__clear_volatile :: proc(input: ^Input) {
	input.wheel = 0
	for &action in input.actions {
		// Clear all inputs besides persisting input actions (DOWN actions).
		action -= ~{.Down}
	}
}
