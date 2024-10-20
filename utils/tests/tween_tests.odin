package tests

import "core:testing"

import "../../utils/tween"

// This code was ported from: github.com/tanema/gween

@(test)
test_new_Tween :: proc(t: ^testing.T) {
	tween := tween.new_Tween(0, 10, 10, tween.ease_linear)

	testing.expect(t, tween.begin == 0)
	testing.expect(t, tween.end == 10)
	testing.expect(t, tween.change == 10)
	testing.expect(t, tween.duration == 10)
	testing.expect(t, tween.time == 0)
	testing.expect(t, tween.overflow == 0)
	testing.expect(t, !tween.reverse)
}

@(test)
test_Tween__set :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	current, finished := tween.Tween__set(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, a_tween.overflow == 0)
	testing.expect(t, !finished)

	current, finished = tween.Tween__set(&a_tween, 11)

	testing.expect(t, current == 10)
	testing.expect(t, a_tween.overflow == 1)
	testing.expect(t, finished)
}

@(test)
test_Tween__set_negative :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	current, finished := tween.Tween__set(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, !finished)

	current, finished = tween.Tween__set(&a_tween, -1)

	testing.expect(t, current == 0)
	testing.expect(t, !finished)
}

@(test)
test_Tween__set_reverse :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	a_tween.reverse = true
	current, finished := tween.Tween__set(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, a_tween.overflow == 0)
	testing.expect(t, !finished)

	current, finished = tween.Tween__set(&a_tween, 11)

	testing.expect(t, current == 10)
	testing.expect(t, a_tween.overflow == 1)
	testing.expect(t, !finished)
}

@(test)
test_Tween__set_negative_reverse :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	a_tween.reverse = true
	current, finished := tween.Tween__set(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, !finished)

	current, finished = tween.Tween__set(&a_tween, -1)

	testing.expect(t, current == 0)
	testing.expect(t, finished)
}

@(test)
test_Tween__reset :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	current, finished := tween.Tween__set(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, a_tween.time == 2)
	testing.expect(t, a_tween.overflow == 0)
	testing.expect(t, !finished)

	tween.Tween__reset(&a_tween)

	testing.expect(t, a_tween.time == 0)
	testing.expect(t, a_tween.overflow == 0)
	testing.expect(t, !finished)
}

@(test)
test_Tween__reset_reverse :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	tween.Tween__set(&a_tween, 2)
	a_tween.reverse = true
	tween.Tween__reset(&a_tween)

	testing.expect(t, a_tween.time == 10)
	testing.expect(t, a_tween.overflow == 0)
}

@(test)
test_Tween__update :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	current, finished := tween.Tween__update(&a_tween, 2)

	testing.expect(t, current == 2)
	testing.expect(t, a_tween.overflow == 0)
	testing.expect(t, !finished)

	current, finished = tween.Tween__update(&a_tween, 9)
	testing.expect(t, current == 10)
	testing.expect(t, a_tween.overflow == 1)
	testing.expect(t, finished)
}

@(test)
test_Tween__update_zero :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	tween.Tween__update(&a_tween, 2)
	current, finished := tween.Tween__update(&a_tween, 0)

	testing.expect(t, current == 2)
	testing.expect(t, !finished)
}

@(test)
test_Tween__update_negative :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	tween.Tween__update(&a_tween, 2)
	current, finished := tween.Tween__update(&a_tween, -1)

	testing.expect(t, current == 1)
	testing.expect(t, !finished)
}

@(test)
test_Tween__update_negative_reverse :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	tween.Tween__update(&a_tween, 2)
	a_tween.reverse = true
	current, finished := tween.Tween__update(&a_tween, -1)

	testing.expect(t, current == 3)
	testing.expect(t, !finished)
}

@(test)
test_Tween__can_reverse :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	tween.Tween__update(&a_tween, 8)
	a_tween.reverse = true
	current, finished := tween.Tween__update(&a_tween, 2)

	testing.expect(t, current == 6)
	testing.expect(t, !finished)
}

@(test)
test_Tween__can_reverse_from_finished :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	current, finished := tween.Tween__update(&a_tween, 10)

	testing.expect(t, finished)

	a_tween.reverse = true
	current, finished = tween.Tween__update(&a_tween, 2)

	testing.expect(t, current == 8)
	testing.expect(t, !finished)
}

@(test)
test_Tween__can_reverse_from_start :: proc(t: ^testing.T) {
	a_tween := tween.new_Tween(0, 10, 10, tween.ease_linear)
	a_tween.reverse = true
	current, finished := tween.Tween__update(&a_tween, 0)

	testing.expect(t, finished)
	testing.expect(t, current == 0)
	testing.expect(t, a_tween.overflow == 0)

	current, finished = tween.Tween__update(&a_tween, 1)
	testing.expect(t, finished)
	testing.expect(t, current == 0)
	testing.expect(t, a_tween.overflow == -1)
}
