extends "res://Utils/State/State.gd"

export var PATH_SIMPLIFY_TIMER = 2
export var OBSTACLE_RAYCAST_TIMER = 1

var simplify_time = 0
var raycast_timer = 0

var los_obstacle = null
var seek_path = [] 
var steering 


func enter(params=null):
	steering = owner.steering
	seek_path = params


func update(delta):
	update_seek_path(delta)
	update_los_obstacle(delta)


func integrate_force(state):
	if not seek_path:
		state.linear_velocity = Vector2()
		emit_signal('finished', 'idle')
		return
	steering.reset()
	var path_size = seek_path.size()
	if path_size == 0:
		emit_signal('finished', 'idle')
		return
	if path_size > 1:
		steering.seek(seek_path[0], 0)
	elif path_size > 0:
		steering.seek(seek_path[0], owner.ARRIVE_DISTANCE)

	if owner.close_boids.size() > 0:
		steering.align(owner.close_boids, 30, 0.2)
		steering.cohesion(owner.close_boids, 30, 0.5)
		steering.seperation(owner.close_boids, 10, 0.6)
#	if close_obstacles.size() > 0:
#		steering.seperation(close_obstacles, 30, 2)
	if los_obstacle:
		steering.collision_avoidance(los_obstacle, 4)
	
	steering.update(state)


func LOS_simplify():
	if !owner.LOS_target_check(seek_path[1]):
		seek_path.remove(0)
		if seek_path.size() > 1:
			LOS_simplify()


func obstacle_raycast():
	var look_point = owner.global_position + owner.linear_velocity.normalized() * owner.MAX_SPEED * 5
	return owner.LOS_target_check(look_point, owner.LOS_WIDTH*2)


func update_seek_path(delta):
	simplify_time += delta
	var path_size = seek_path.size()
	if path_size == 0:
		return
	var distance_to_next = owner.position.distance_to(seek_path[0])
	if path_size == 1 and owner.linear_velocity.length() < 1 and distance_to_next < 10:
		seek_path.remove(0)
		return

	if seek_path.size() > 1  and (simplify_time > PATH_SIMPLIFY_TIMER || distance_to_next < owner.linear_velocity.length()) :
		simplify_time = 0
		LOS_simplify()


func update_los_obstacle(delta):
	raycast_timer += delta
	if (raycast_timer > OBSTACLE_RAYCAST_TIMER):
		raycast_timer = 0
		var obstacle = obstacle_raycast()
		if obstacle:
			los_obstacle = obstacle.position
		else:
			los_obstacle = null


func _draw():
	if seek_path.size() > 0:
		owner.draw_circle(seek_path[0] - owner.position, 10, Color.blue)
		owner.draw_line(Vector2(), steering.steering_force*30, Color.red)
		owner.draw_line(Vector2(), owner.linear_velocity, Color.green)

		if (seek_path.size() > 1):
			var ray_tangent = (owner.position - seek_path[1]).tangent().normalized()
			var ray_offset = ray_tangent * owner.LOS_WIDTH
			owner.draw_line(ray_offset, seek_path[1] + ray_offset - owner.position, Color.brown)
			owner.draw_line(-ray_offset, seek_path[1] - ray_offset - owner.position, Color.brown)