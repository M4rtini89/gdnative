extends "res://Utils/State/State.gd"

var state_time = 0
const state_time_limit = 3

func enter():
	state_time = 0
	print("entered idle state")
	print("owner: %s" % owner)

func exit():
	print("exited idle state")

func update(delta):
	state_time += delta
	if (state_time > state_time_limit):
		emit_signal('finished', 'idle')