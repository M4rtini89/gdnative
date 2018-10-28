extends "res://addons/godot-behavior-tree-plugin/condition.gd"

export(int) var sight_range

func tick(tick):
    var actor = tick.actor
    var team = actor.team
    var close_boids = actor.close_boids

    for boid in close_boids:
        if boid.team != team and actor.position.distance_to(boid.position) <= sight_range:
            #TODO: Only update enemy_in_range if the previous one has died or gone out of range.
            tick.blackboard.set("enemy_in_range", boid)
            return OK
    
    return FAILED
    
