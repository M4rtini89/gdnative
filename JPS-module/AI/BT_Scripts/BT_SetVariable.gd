extends "res://addons/godot-behavior-tree-plugin/action.gd"

export(String) var _key 
export(String) var _value 

func open(tick):
	var value = tick.blackboard.get(_value)
	tick.blackboard.set(_key, value)
	return OK