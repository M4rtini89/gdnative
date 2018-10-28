extends Node2D

export var damage = 5
export var fire_range = 25
export var fire_rate = 0.5 # Shots per second
export(PackedScene) var explosion_scene


onready var shoot_timer = $CanShootTimer
onready var Health_component = preload("res://Entities/Health.gd")
#onready var Health_component = 


var can_shoot = true

func _ready():
    shoot_timer.wait_time = 1.0 / fire_rate


func shoot(target):
    if not can_shoot:
        return
    if not is_target_in_range(target):
        return false
    for child_node in target.get_children():
        if child_node is Health:
            _shoot(target)
            return


func _shoot(target):
    #Do damage
    can_shoot = false
    shoot_timer.start()
    target.take_damage(damage)
    
    #Show visual
    var explosion = explosion_scene.instance()
    explosion.position = target.position
    explosion.owner = owner.get_parent()
    owner.get_parent().add_child(explosion)


func is_target_in_range(target):
    var target_distance = global_position.distance_to(target.global_position)
    return target_distance < fire_range

func _on_CanShootTimer_timeout():
    can_shoot = true
