extends RigidBody2D

export var MAX_SPEED = 50
export var MAX_FORCE = 2
export var ARRIVE_DISTANCE = 10
export var DRAW_DEBUG = true
export var LOS_WIDTH = 5


var close_boids = []
var close_obstacles = []


var steering = preload("res://AI/SteeringManager.gd").new()

onready var sprite = $Sprite
onready var selection_ring = $SelectionVisual
onready var state_machine = $BoidStateMachine

var selected setget set_selected

func set_selected(value):
	selected = value
	selection_ring.visible = selected

func _ready():
	steering.host = self
	self.selected = false
	state_machine.start()

func _process(delta):
	if DRAW_DEBUG:
		update()
	if linear_velocity.length() > 1:
		update_sprite(delta)


func update_sprite(delta):
	var angle = linear_velocity.angle()
	sprite.rotation = angle
	angle *= 180 / PI 
	if angle < -90 or angle > 90:
		sprite.flip_v = true	
	else:
		sprite.flip_v = false


func _input(event):
	if Input.is_action_just_pressed("click") and selected:
		var new_target = get_global_mouse_position()
		var seek_path = null
		if !LOS_target_check(new_target):
			seek_path = [new_target]
		else:
			seek_path = Global.Level.query_path(position, new_target)
			if seek_path.size() > 0:
				seek_path.append(new_target)
		if seek_path and sleeping:
			#set_sleeping(false)  
			#apply_central_impulse(Vector2(1,1))
			# hack because the above does not work unless you do it several times..
			wake_up()
		if seek_path:
				state_machine._change_state("move", seek_path)


func LOS_target_check(target, ray_width=LOS_WIDTH):
	var ray_tangent = (global_position - target).tangent().normalized()
	var ray_offset = ray_tangent * ray_width
	
	var space = get_world_2d().direct_space_state
	var offsets = [Vector2(), -ray_offset, ray_offset]
	for offset in offsets:
		var raycast_res = _raycast_obstacles(space, target, offset)
		if raycast_res:
			return raycast_res
	return null


func _raycast_obstacles(space, target, offset):
	var LOS_obstacle = space.intersect_ray(global_position - offset, target - offset, [self], Global.Obstacle_collision_mask)
	if LOS_obstacle.empty():
		return null
	else:
		return LOS_obstacle
	

func wake_up():
	apply_central_impulse(Vector2(10,10))


func _integrate_forces(state):
	steering.reset()
	state_machine.current_state.integrate_force(state)
	steering.update(state)


func _draw():
	if DRAW_DEBUG and  state_machine.current_state.has_method("_draw"):
		state_machine.current_state._draw()


func _on_Area2D_body_entered(body):
	if body != self:
		if body.get_collision_layer_bit(3):
			close_obstacles.append(body)
		else:
			close_boids.append(body)


func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(3):
		close_obstacles.erase(body)
	else:
		close_boids.erase(body)