extends RigidBody2D

export var MAX_SPEED = 50
export var MAX_FORCE = 2
export var ARRIVE_DISTANCE = 15
export var DRAW_DEBUG = false
export var LOS_WIDTH = 5

var seek_path = [] 

var close_boids = []
var close_obstacles = []

var steering = preload("res://SteeringManager.gd").new()

onready var sprite = $Sprite

func _ready():
	steering.host = self

func _process(delta):
	if DRAW_DEBUG:
		update()
	if seek_path:
		update_sprite()
	


func update_sprite():
	var angle = linear_velocity.angle()
	sprite.rotation = angle
	angle *= 180 / PI 
	if angle < -90 or angle > 90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false


func _physics_process(delta):
	update_seek_path()

	if Input.is_action_just_pressed("click"):
		var new_target = get_global_mouse_position()
		seek_path = Global.Level.query_path(position, new_target)
		#print(seek_path)
		if sleeping:
			#set_sleeping(false)  
			#apply_central_impulse(Vector2(1,1))
			# hack because the above does not work unless you do it several times..
			wake_up()


func update_seek_path():
	var path_size = seek_path.size()
	if path_size == 0:
		return
	var distance_to_next = position.distance_to(seek_path[0])
	if path_size == 1 and linear_velocity.length() < 1 and distance_to_next < 10:
#		print(linear_velocity)
		seek_path.remove(0)
		return

#	if path_size > 0 and distance_to_next < linear_velocity.length()*0.25:
#		seek_path.remove(0)
	if seek_path.size() > 1:
		LOS_simplify()
#		if (distance_to_next < 5):
#			seek_path.remove(0)


func LOS_simplify():
	var ray_tangent = (global_position - seek_path[1]).tangent().normalized()
	var ray_offset = ray_tangent * LOS_WIDTH
	
	var space = get_world_2d().direct_space_state
	
	var LOS_obstacle = space.intersect_ray(global_position + ray_offset, seek_path[1] + ray_offset, [self], Global.Obstacle_collision_mask)
	if LOS_obstacle.empty():
		LOS_obstacle = space.intersect_ray(global_position - ray_offset, seek_path[1] - ray_offset, [self], Global.Obstacle_collision_mask)
		if LOS_obstacle.empty():
			seek_path.remove(0)
			if seek_path.size() > 1:
				LOS_simplify()

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
		#steering.align(close_boids, 100, 1)
		steering.cohesion(close_boids, 40, 1)
		steering.seperation(close_boids, 15, 2)
	if close_obstacles.size() > 0:
		steering.seperation(close_obstacles, 40, 8)
	steering.update(state)




func _draw():
	if seek_path.size() > 0:
		draw_line(Vector2(), steering.steering_force*30, Color.red)
		draw_line(Vector2(), linear_velocity, Color.green)
		draw_circle(seek_path[0] - position, 10, Color.blue)
		
		if (seek_path.size() > 1):
			var ray_tangent = (position - seek_path[1]).tangent().normalized()
			var ray_offset = ray_tangent * LOS_WIDTH
			draw_line(ray_offset, seek_path[1] + ray_offset - position, Color.brown)
			draw_line(-ray_offset, seek_path[1] - ray_offset - position, Color.brown)


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