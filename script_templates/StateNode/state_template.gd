# meta-description: Base template for a StateNode script
# meta-default: true

extends _BASE_


# Called by a StateMachine once it is ready
func _state_machine_ready() -> void:
	pass

# Called by a StateMachine when the state is entered.
# previous_state is the name of the previous StateNode.
func _enter_state(previous_state):
	pass

# Called by a StateMachine when the state is exited.
# next_state is the name of the next StateNode.
func _exit_state(next_state):
	pass

# Called by a StateMachine each process frame (idle) with the
# time since the last process frame as argument. (delta, in seconds.)
func _process_state(delta):
	pass

# Called by a StateMachine each physics frame with the time since
# the last physics frame as argument. (delta, in seconds.)
func _physics_process_state(delta):
	pass
