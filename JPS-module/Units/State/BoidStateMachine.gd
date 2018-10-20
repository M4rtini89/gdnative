extends "res://Utils/State/StateMachine.gd"

func _ready():
	states_map = {
		'idle': $Idle,
		'move' : $Move
	}
	for state in get_children():
		state.connect('finished', self, '_change_state')