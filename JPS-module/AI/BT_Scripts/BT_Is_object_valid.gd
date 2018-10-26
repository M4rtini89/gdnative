extends "res://addons/godot-behavior-tree-plugin/condition.gd"

export(String) var variable

func tick(tick):
	var obj = tick.blackboard.get(variable)
	if is_instance_valid(obj):
		return OK
	else:
		return FAILED