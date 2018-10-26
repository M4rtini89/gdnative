extends "res://addons/godot-behavior-tree-plugin/action.gd"


func tick(tick):
	var state = tick.blackboard.get("physics_state")
	state.linear_velocity = Vector2()
	return OK