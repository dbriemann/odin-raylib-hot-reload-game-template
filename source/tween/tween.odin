package tween

// This code was ported from: github.com/tanema/gween

// Tween encapsulates the easing function along with timing data. 
// This allows an Ease_Func to be used to be easily animated.
Tween :: struct {
	duration:  f32,
	time:      f32,
	begin:     f32,
	end:       f32,
	range:     f32,
	overflow:  f32,
	ease_func: Ease_Func,
	reverse:   bool,
}

// new_Tween will return a new Tween when passed:
// a beginning and end value,
// the duration of the tween in seconds,
// and the easing function to animate between the two values.
// The easing function can be one of the provided easing functions or you can provide one of your own.
new_Tween :: proc(begin, end, duration: f32, ease_func: Ease_Func) -> Tween {
	t := Tween {
		begin     = begin,
		end       = end,
		duration  = duration,
		range     = end - begin,
		ease_func = ease_func,
		overflow  = 0,
		reverse   = false,
	}

	return t
}

// Tween__set will set the current time along the duration of the tween.
// It will then return the current value as well as a boolean to determine if the tween is finished.
Tween__set :: proc(tween: ^Tween, time: f32) -> (current: f32, finished: bool) {
	switch {
	case time <= 0:
		tween.overflow = time
		tween.time = 0
		current = tween.begin
	case time >= tween.duration:
		tween.overflow = time - tween.duration
		tween.time = tween.duration
		current = tween.end
	case:
		tween.overflow = 0
		tween.time = time
		current = tween.ease_func(tween.time, tween.begin, tween.range, tween.duration)
	}

	if tween.reverse {
		finished = tween.time <= 0
	} else {
		finished = tween.time >= tween.duration
	}
	return
}

// Tween__reset will set the Tween to the beginning of the two values.
Tween__reset :: proc(tween: ^Tween) {
	if tween.reverse {
		Tween__set(tween, tween.duration)
	} else {
		Tween__set(tween, 0)
	}
}

// Tween__update will increment the timer of the Tween and ease the value.
// It will then return the current value as well as a bool to mark if the tween is finished or not.
Tween__update :: proc(tween: ^Tween, dt: f32) -> (current: f32, finished: bool) {
	next := tween.time + dt
	if tween.reverse {
		next = tween.time - dt
	}
	current, finished = Tween__set(tween, next)

	return
}
