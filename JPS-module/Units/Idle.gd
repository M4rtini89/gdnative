extends "res://Utils/State/State.gd"

var idle_pos = Vector2()

func enter(params=null):
	# TODO: Make it move out of the way for allied units. 
	# Possibly seek back to idle pos afterwards.
	idle_pos = Vector2()
	print("entered idle state")
	owner.linear_damp = 5

func exit():
	owner.linear_damp = -1

