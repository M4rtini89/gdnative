extends "res://addons/godot-behavior-tree-plugin/bt_base.gd"

export(float) var wait_time = 0.0

var last_time = 0.0


func open(tick):
	last_time = 0


# Decorator Node
func tick(tick):
	last_time += tick.blackboard.get("delta")
	if last_time > wait_time:
		print("done waiting") 
		return OK
	else:
		return ERR_BUSY
