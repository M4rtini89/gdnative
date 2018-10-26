extends "res://addons/godot-behavior-tree-plugin/condition.gd"

export(float) var timeout = 0

# It should always run once first
var timer = 999999

func tick(tick):
	timer += tick.blackboard.get("delta")
	if timer >= timeout:
		timer = 0
		return FAILED
	else:
		return OK