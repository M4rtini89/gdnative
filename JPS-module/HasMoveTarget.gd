extends "res://addons/godot-behavior-tree-plugin/condition.gd"

#check that the actor actually have a target to move to.

func tick(tick):
	var seek_path = tick.blackboard.get("seek_path")
	if seek_path:
		return OK
	else:
		return FAILED