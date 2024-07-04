extends "common_state.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"crouch")


func _physics_process_state(_delta: float) -> String:
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.025)

	else:
		return "Fall"

	return ""


func _unhandled_input_state(event: InputEvent) -> String:
	if event.is_action_released(&"crouch"):
		get_viewport().set_input_as_handled()
		return get_state_machine().get_previous_state()
	return ""
