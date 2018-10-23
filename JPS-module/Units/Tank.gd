extends "res://Units/boid.gd"

export var unit_name = "Tank"

onready var Health = $Health


func take_damage(value):
	Health.take_damage(value)


func die():
	queue_free()