extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	var enemy = tick.blackboard.get("enemy_in_range")
	var actor : Tank = tick.actor
	actor.attack(enemy)
	return OK