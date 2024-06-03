extends Node


func lerp_clamped(from, to, weight):
	return lerp(from, to, clamp(weight, 0, 1))
