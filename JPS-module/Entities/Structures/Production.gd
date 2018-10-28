extends Node2D

export(PackedScene) var tank_scene
export(int) var build_time

onready var build_timer : Timer = $BuildTimer
onready var build_progress = $BuildProgress

func _ready():
    build_progress.visible = false


func _process(delta):
    if is_building():
        var progress = 100 * (1 - build_timer.time_left / build_time)
        build_progress.value = progress
        

func _input(event):
    if event.is_action_pressed("debug_key"):
        start_build()


func start_build():
    if build_timer.is_stopped():
        build_progress.visible = true
        build_timer.start(build_time)


func _on_BuildTimer_timeout():
    build_progress.visible = false
    place_unit()
    
func is_building():
    return not build_timer.is_stopped()


func place_unit():
    var spawn_point = global_position + Vector2(0, 16)
    var unit_node = tank_scene.instance()
    unit_node.position = spawn_point
    unit_node.team = get_parent().team
    var global_units = Global.Level.units
    global_units.add_child(unit_node)
    unit_node.owner = global_units

