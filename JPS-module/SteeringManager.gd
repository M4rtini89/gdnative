var steering_force = Vector2()
var host : RigidBody2D


# Needs to be called in _integrate_forces of host
func update(state):
	steering_force /= host.mass
	steering_force = steering_force.clamped(host.MAX_FORCE)
	
	state.linear_velocity = (state.linear_velocity + steering_force).clamped(host.MAX_SPEED)

# Reset the steering force
func reset():
	steering_force = Vector2()

func seek(target, arrive_distance, weight=1):
	steering_force += _seek(target, arrive_distance) * weight

func _seek(target, arrive_distance):
	var desired_velocity = target - host.position
	var distance = desired_velocity.length()
	if distance < arrive_distance:
		desired_velocity = desired_velocity.normalized() * host.MAX_SPEED * (distance / arrive_distance)
	else:
		desired_velocity = desired_velocity.normalized() * host.MAX_SPEED
	return (desired_velocity - host.linear_velocity)


func flee(target, arrive_distance, weight = 1):
	steering_force += _flee(target) * weight


func _flee(target):
	var desired_velocity = (host.position - target).normalized()
	desired_velocity *= host.MAX_SPEED
	return (desired_velocity - host.linear_velocity)


func align(neighbours, align_radius, weight = 1):
	steering_force += _align(neighbours, align_radius) * weight

	
func _align(neighbours, align_radius):
	var desired_velocity = Vector2()
	var neighbour_count = 0
	for boid in neighbours:
		if host.position.distance_to(boid.position) < align_radius:
			neighbour_count += 1
			desired_velocity += boid.linear_velocity
	if neighbour_count > 0:
		desired_velocity /= neighbour_count
	desired_velocity = desired_velocity.normalized()
	return desired_velocity
	
func cohesion(neighbours, cohesion_radius, weight = 1):
	steering_force += _cohesion(neighbours, cohesion_radius) * weight

func _cohesion(neighbours, cohesion_radius):
	var center = host.position
	var neighbour_count = 1
	for boid in neighbours:
		if host.position.distance_to(boid.position) < cohesion_radius:
			neighbour_count += 1
			center  += boid.position
	center /= neighbour_count
	return (center - host.position).normalized()	


func seperation(neighbours, seperation_radius, weight):
	steering_force += _separation(neighbours, seperation_radius) * weight


func _separation(neighbours, seperation_radius):
	var desired_velocity = Vector2( 0, 0 )
	var neighbour_count = 0
	for boid in neighbours:
		var dist_vec = boid.position - host.position
		var distance = host.position.distance_to(boid.position)
		if distance < seperation_radius:
			neighbour_count += 1
			desired_velocity -= dist_vec
	if neighbour_count > 0:
		desired_velocity /= neighbour_count
	return desired_velocity.normalized()
