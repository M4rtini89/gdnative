extends RigidBody2D

export var MAX_SPEED = 50
export var MAX_FORCE = 4
export var ARRIVE_DISTANCE = 15
export var DRAW_DEBUG = false
export var LOS_WIDTH = 5

const PATH_SIMPLIFY_TIMER = 2
const OBSTACLE_RAYCAST_TIMER = 1

var simplify_time = 0
var raycast_timer = 0


var seek_path = [] 
var close_boids = []
var close_obstacles = []
var los_obstacle = null

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
	if seek_path:
		update_sprite(delta)


func update_sprite(delta):
	var angle = linear_velocity.angle()
	sprite.rotation = angle
	angle *= 180 / PI 
	if angle < -90 or angle > 90:
		sprite.flip_v = true	
	else:
		sprite.flip_v = false


func _physics_process(delta):
	update_seek_path(delta)
	raycast_timer += delta
	if (raycast_timer > OBSTACLE_RAYCAST_TIMER):
		raycast_timer = 0
		var obstacle = obstacle_raycast()
		if obstacle:
			los_obstacle = obstacle.position
		else:
			los_obstacle = null

	if Input.is_action_just_pressed("click") and selected:
		var new_target = get_global_mouse_position()
		if !LOS_target_check(new_target):
			seek_path = [new_target]
		else:
			seek_path = Global.Level.query_path(position, new_target)
			if seek_path.size() > 0:
				seek_path.append(new_target)
		if sleeping:
			#set_sleeping(false)  
			#apply_central_impulse(Vector2(1,1))
			# hack because the above does not work unless you do it several times..
			wake_up()


func update_seek_path(delta):
	simplify_time += delta
	var path_size = seek_path.size()
	if path_size == 0:
		return
	var distance_to_next = position.distance_to(seek_path[0])
	if path_size == 1 and linear_velocity.length() < 1 and distance_to_next < 10:
		seek_path.remove(0)
		return

	if seek_path.size() > 1  and (simplify_time > PATH_SIMPLIFY_TIMER || distance_to_next < linear_velocity.length()) :
		simplify_time = 0
		LOS_simplify()
#		if (distance_to_next < 5):
#			seek_path.remove(0)


func LOS_target_check(target, ray_width=LOS_WIDTH):
	var ray_tangent = (global_position - target).tangent().normalized()
	var ray_offset = ray_tangent * ray_width
	var space = get_world_2d().direct_space_state
	var raycast_res = _raycast_obstacles(space, target, ray_offset)
	if raycast_res:
		return raycast_res
	
	raycast_res = _raycast_obstacles(space, target, -ray_offset)
	if raycast_res:
		return raycast_res
	else:
		return null

func LOS_simplify():
	if !LOS_target_check(seek_path[1]):
		seek_path.remove(0)
		if seek_path.size() > 1:
			LOS_simplify()
#	var ray_tangent = (global_position - seek_path[1]).tangent().normalized()
#	var ray_offset = ray_tangent * LOS_WIDTH
#
#	var space = get_world_2d().direct_space_state
#	if !_raycast_obstacles(space, seek_path[1], ray_offset) and !_raycast_obstacles(space, seek_path[1], -ray_offset):
#		 seek_path.remove(0)
#			if seek_path.size() > 1:
#				LOS_simplify()
#

func _raycast_obstacles(space, target, offset):
	var LOS_obstacle = space.intersect_ray(global_position - offset, target - offset, [self], Global.Obstacle_collision_mask)
	if LOS_obstacle.empty():
		return null
	else:
		return LOS_obstacle
	
func obstacle_raycast():
	var look_point = global_position + linear_velocity.normalized() * MAX_SPEED * 5
	return LOS_target_check(look_point, LOS_WIDTH*2)
#	var ray_tangent = linear_velocity.tangent().normalized()
#	var ray_offset = ray_tangent * (LOS_WIDTH*2)
#	var space = get_world_2d().direct_space_state
#
#
#	var obstacles = _raycast_obstacles(space, look_point, ray_offset)
#	if not obstacles:
#		obstacles = _raycast_obstacles(space, look_point, -ray_offset)
#	if not obstacles:
#		return null
#	return obstacles
	

func wake_up():
	apply_central_impulse(Vector2(10,10))

func _integrate_forces(state):
	if not seek_path:
		state.linear_velocity = Vector2()
		return
	steering.reset()
	var path_size = seek_path.size()
	if path_size > 1:
		steering.seek(seek_path[0], 0)
	elif path_size > 0:
		steering.seek(seek_path[0], ARRIVE_DISTANCE)
	if close_boids.size() > 0:
		steering.align(close_boids, 30, 0.2)
		steering.cohesion(close_boids, 30, 0.5)
		steering.seperation(close_boids, 10, 0.6)
#	if close_obstacles.size() > 0:
#		steering.seperation(close_obstacles, 30, 2)
	if los_obstacle:
		steering.collision_avoidance(los_obstacle, 4)
	steering.update(state)




func _draw():
	if seek_path.size() > 0:
		draw_circle(seek_path[0] - position, 10, Color.blue)
		draw_line(Vector2(), steering.steering_force*30, Color.red)
		draw_line(Vector2(), linear_velocity, Color.green)
		
#		if (seek_path.size() > 1):
#			var ray_tangent = (position - seek_path[1]).tangent().normalized()
#			var ray_offset = ray_tangent * LOS_WIDTH
#			draw_line(ray_offset, seek_path[1] + ray_offset - position, Color.brown)
#			draw_line(-ray_offset, seek_path[1] - ray_offset - position, Color.brown)


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