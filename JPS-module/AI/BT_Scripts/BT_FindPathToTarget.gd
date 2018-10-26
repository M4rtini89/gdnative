extends "res://addons/godot-behavior-tree-plugin/action.gd"

export(String) var target_var

func tick(tick):
	var actor : Boid = tick.actor
	var path = actor._get_path(tick.blackboard.get(target_var).position)
	if path:
		tick.blackboard.set("seek_path", path)
		return OK
	else:
		return FAILED