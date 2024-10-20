package tween

import "core:math"

// This code was ported from: github.com/tanema/gween

BACK_S :: 1.70158

// Ease_Func defines a proc type for all easing equations.
// t = current time, b = begin value, c = change from begin, d = duration
Ease_Func :: proc(t, b, c, d: f32) -> f32

// ease_linear is a linear interpolation of some t with respect to a total duration d between the values b and b+c.
ease_linear :: proc(t, b, c, d: f32) -> f32 {
	return c * t / d + b
}

// ease_in_quad is a quadratic transition based on the square of t that starts slow and speeds up.
ease_in_quad :: proc(t, b, c, d: f32) -> f32 {
	return c * math.pow(t / d, 2) + b
}

// ease_out_quad is a quadratic transition based on the square of t that starts fast and slows down.
ease_out_quad :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d
	return -c * t * (t - 2) + b
}

// ease_in_out_quad is a quadratic transition based on the square of t that starts and ends slow, accelerating through the middle.
ease_in_out_quad :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * math.pow(t, 2) + b
	}
	return -c / 2 * ((t - 1) * (t - 3) - 1) + b
}

// ease_out_in_quad is a quadratic transition based on the square of t that starts and ends fast, slowing through the middle.
ease_out_in_quad :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_quad(t * 2, b, c / 2, d)
	}
	return ease_in_quad((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_cubic is a cubic transition based on the cube of t that starts slow and speeds up.
ease_in_cubic :: proc(t, b, c, d: f32) -> f32 {
	return c * math.pow(t / d, 3) + b
}

// ease_out_cubic is a cubic transition based on the cube of t that starts fast and slows down.
ease_out_cubic :: proc(t, b, c, d: f32) -> f32 {
	return c * (math.pow(t / d - 1, 3) + 1) + b
}

// ease_in_out_cubic is a cubic transition based on the cube of t that starts and ends slow, accelerating through the middle.
ease_in_out_cubic :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * t * t * t + b
	}
	t -= 2
	return c / 2 * (t * t * t + 2) + b
}

// ease_out_in_cubic is a cubic transition based on the cube of t that starts and ends fast, slowing through the middle.
ease_out_in_cubic :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_cubic(t * 2, b, c / 2, d)
	}
	return ease_in_cubic((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_quart is a quartic transition based on the fourth power of t that starts slow and speeds up.
ease_in_quart :: proc(t, b, c, d: f32) -> f32 {
	return c * math.pow(t / d, 4) + b
}

// ease_out_quart is a quartic transition based on the fourth power of t that starts fast and slows down.
ease_out_quart :: proc(t, b, c, d: f32) -> f32 {
	return -c * (math.pow(t / d - 1, 4) - 1) + b
}

// ease_in_out_quart is a quartic transition based on the fourth power of t that starts and ends slow, accelerating through the middle.
ease_in_out_quart :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * math.pow(t, 4) + b
	}
	return -c / 2 * (math.pow(t - 2, 4) - 2) + b
}

// ease_out_in_quart is a quartic transition based on the fourth power of t that starts and ends fast, slowing through the middle.
ease_out_in_quart :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_quart(t * 2, b, c / 2, d)
	}
	return ease_in_quart((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_quint is a quintic transition based on the fifth power of t that starts slow and speeds up.
ease_in_quint :: proc(t, b, c, d: f32) -> f32 {
	return c * math.pow(t / d, 5) + b
}

// ease_out_quint is a quintic transition based on the fifth power of t that starts fast and slows down.
ease_out_quint :: proc(t, b, c, d: f32) -> f32 {
	return c * (math.pow(t / d - 1, 5) + 1) + b
}

// ease_in_out_quint is a quintic transition based on the fifth power of t that starts and ends slow, accelerating through the middle.
ease_in_out_quint :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * math.pow(t, 5) + b
	}
	return c / 2 * (math.pow(t - 2, 5) + 2) + b
}

// ease_out_in_quint is a quintic transition based on the fifth power of t that starts and ends fast, slowing through the middle.
ease_out_in_quint :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_quint(t * 2, b, c / 2, d)
	}
	return ease_in_quint((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_sine is a sinusoidal transition based on the cosine of t that starts slow and speeds up.
ease_in_sine :: proc(t, b, c, d: f32) -> f32 {
	return -c * math.cos(t / d * (math.PI / 2)) + c + b
}

// ease_out_sine is a sinusoidal transition based on the sine or cosine of t that starts fast and slows down.
ease_out_sine :: proc(t, b, c, d: f32) -> f32 {
	return c * math.sin(t / d * (math.PI / 2)) + b
}

// ease_in_out_sine is a sinusoidal transition based on the cosine of t that starts and ends slow, accelerating through the middle.
ease_in_out_sine :: proc(t, b, c, d: f32) -> f32 {
	return -c / 2 * (math.cos(math.PI * t / d) - 1) + b
}

// ease_out_in_sine is a sinusoidal transition based on the sine or cosine of t that starts and ends fast, slowing through the middle.
ease_out_in_sine :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_sine(t * 2, b, c / 2, d)
	}
	return ease_in_sine((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_expo is a exponential transition based on the 2 to power 10*t that starts slow and speeds up.
ease_in_expo :: proc(t, b, c, d: f32) -> f32 {
	if t == 0 {
		return b
	}
	return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001
}

// ease_out_expo is a exponential transition based on the 2 to power 10*t that starts fast and slows down.
ease_out_expo :: proc(t, b, c, d: f32) -> f32 {
	if t == d {
		return b + c
	}
	return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b
}

// ease_in_out_expo is a exponential transition based on the 2 to power 10*t that starts and ends slow, accelerating through the middle.
ease_in_out_expo :: proc(t, b, c, d: f32) -> f32 {
	if t == 0 {
		return b
	}
	if t == d {
		return b + c
	}
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005
	}
	return c / 2 * 1.0005 * (-math.pow(2, -10 * (t - 1)) + 2) + b
}

// ease_out_in_expo is a exponential transition based on the 2 to power 10*t that starts and ends fast, slowing through the middle.
ease_out_in_expo :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_expo(t * 2, b, c / 2, d)
	}
	return ease_in_expo((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_circ is a circular transition based on the equation for half of a circle, taking the square root of t, that starts slow and speeds up.
ease_in_circ :: proc(t, b, c, d: f32) -> f32 {
	return -c * (math.sqrt(1 - math.pow(t / d, 2)) - 1) + b
}

// ease_out_circ is a circular transition based on the equation for half of a circle, taking the square root of t, that starts fast and slows down.
ease_out_circ :: proc(t, b, c, d: f32) -> f32 {
	return c * math.sqrt(1 - math.pow(t / d - 1, 2)) + b
}

// ease_in_out_circ is a circular transition based on the equation for half of a circle, taking the square root of t, that starts and ends slow, accelerating through the middle.
ease_in_out_circ :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d * 2
	if t < 1 {
		return -c / 2 * (math.sqrt(1 - t * t) - 1) + b
	}
	t -= 2
	return c / 2 * (math.sqrt(1 - t * t) + 1) + b
}

// ease_out_in_circ is a circular transition based on the equation for half of a circle, taking the square root of t, that starts and ends fast, slowing through the middle.
ease_out_in_circ :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_circ(t * 2, b, c / 2, d)
	}
	return ease_in_circ((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_elastic is an elastic transition that wobbles around from the start value, extending past start and away from end, and then accelerates towards the end value at the end of the transition.
ease_in_elastic :: proc(t, b, c, d: f32) -> f32 {
	if t == 0 {
		return b
	}
	t := t
	t = t / d
	if t == 1 {
		return b + c
	}
	p, a, s := calculatePAS(c, d)
	t -= 1
	return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.PI) / p)) + b
}

// ease_out_elastic is an elastic transition that accelerates quickly away from the start and beyond the end value and then wobbles towards the end value at the end of the transition.
ease_out_elastic :: proc(t, b, c, d: f32) -> f32 {
	if t == 0 {
		return b
	}
	t := t
	t = t / d
	if t == 1 {
		return b + c
	}
	p, a, s := calculatePAS(c, d)
	return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.PI) / p) + c + b
}

// ease_in_out_elastic is an elastic transition that wobbles around from the start value, towards the middle of the transition extending beyond start away from end, then rapidly toward, and beyond end value, then wobbling toward end.
ease_in_out_elastic :: proc(t, b, c, d: f32) -> f32 {
	if t == 0 {
		return b
	}
	t := t
	t = t / d * 2
	if t == 2 {
		return b + c
	}
	p, a, s := calculatePAS(c, d)
	t -= 1
	if t < 0 {
		return -0.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.PI) / p)) + b
	}
	return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.PI) / p) * 0.5 + c + b
}

// ease_out_in_elastic is an elastic transition that accelerates towards and beyond the average of the start and end values, wobbles toward the average, wobbles out and slight away from end before accelerating toward the end value.
ease_out_in_elastic :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_elastic(t * 2, b, c / 2, d)
	}
	return ease_in_elastic((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_in_back is a much like InQuint, but extends beyond the start away from end before snapping quickly to the end.
ease_in_back :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d
	return c * t * t * ((BACK_S + 1) * t - BACK_S) + b
}

// ease_out_back is a much like OutQuint, but extends beyond the end away from start before easing toward end.
ease_out_back :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t / d - 1
	return c * (t * t * ((BACK_S + 1) * t + BACK_S) + 1) + b
}

// ease_in_out_back is a much like InOutQuint, but extends beyond both start and end values on both sides of the transition.
ease_in_out_back :: proc(t, b, c, d: f32) -> f32 {
	s: f32 = BACK_S * 1.525
	t := t
	t = t / d * 2
	if t < 1 {
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	}
	t -= 2
	return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
}

// ease_out_in_back is a much like OutInQuint, but extends beyond the average of start and end during the middle of the transition.
ease_out_in_back :: proc(t, b, c, d: f32) -> f32 {
	if t < (d / 2) {
		return ease_out_back(t * 2, b, c / 2, d)
	}
	return ease_in_back((t * 2) - d, b + c / 2, c / 2, d)
}

// ease_out_bounce is a bouncing transition that accelerates toward the end value and then bounces back slightly in decreasing amounts until coming to reset at end.
ease_out_bounce :: proc(t, b, c, d: f32) -> f32 {
	t := t
	t = t
	t = t / d
	if t < 1 / 2.75 {
		return c * (7.5625 * t * t) + b
	}
	if t < 2 / 2.75 {
		t -= 1.5 / 2.75
		return c * (7.5625 * t * t + 0.75) + b
	} else if t < 2.5 / 2.75 {
		t -= 2.25 / 2.75
		return c * (7.5625 * t * t + 0.9375) + b
	}
	t -= 2.625 / 2.75
	return c * (7.5625 * t * t + 0.984375) + b
}

// ease_in_bounce is a bouncing transition that slowly bounces away from start at increasing amounts before finally accelerating toward end.
ease_in_bounce :: proc(t, b, c, d: f32) -> f32 {
	return c - ease_out_bounce(d - t, 0, c, d) + b
}

// ease_in_out_bounce is a bouncing transition that bounces off of the start value, then accelerates toward the average of start and end, then does the opposite toward the end value.
ease_in_out_bounce :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_in_bounce(t * 2, 0, c, d) * 0.5 + b
	}
	return ease_out_bounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
}

// ease_out_in_bounce is a bouncing transition that accelerates toward the average of start and end, bouncing off of the average toward start, then flips and bounces off of average toward end in increasing amounts before accelerating toward end.
ease_out_in_bounce :: proc(t, b, c, d: f32) -> f32 {
	if t < d / 2 {
		return ease_out_bounce(t * 2, b, c / 2, d)
	}
	return ease_in_bounce((t * 2) - d, b + c / 2, c / 2, d)
}

calculatePAS :: proc(c, d: f32) -> (p, a, s: f32) {
	p = d * 0.3
	return p, c, p / 4
}
