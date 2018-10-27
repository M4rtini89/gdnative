extends Node2D

var sound_done = false
var anim_done = false
var random_pos_range = 5

func _ready():
	$SFX.pitch_scale = rand_range(0.8, 1.2)
	position += Vector2(rand_range(-random_pos_range, random_pos_range), rand_range(-random_pos_range, random_pos_range))


func _on_SFX_finished():
	sound_done = true
	if anim_done:
		queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	anim_done = true
	if sound_done:
		queue_free()
