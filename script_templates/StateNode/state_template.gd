# meta-description: Base template for a StateNode script
# meta-default: true

extends _BASE_


# Called by a StateMachine once it is ready.
func _state_machine_ready() -> void:
	pass


# Called by a StateMachine when the state is entered.
func _enter_state(old_state, state_data: Dictionary):
	pass


# Called by a StateMachine when the state is exited.
func _exit_state(new_state, state_data: Dictionary):
	pass
