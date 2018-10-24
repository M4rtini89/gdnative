tool
extends "res://Units/boid.gd"

export var unit_name = "Tank"

onready var Health = $Health
onready var WeaponSystem = $Weapon


func take_damage(value):
	Health.take_damage(value)


func attack(target):
	try_to_shoot(target)

func try_to_shoot(target):
		WeaponSystem.shoot(target)


func die():
	queue_free()