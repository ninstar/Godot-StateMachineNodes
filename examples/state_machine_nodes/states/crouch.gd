extends "common_state.gd"


func _enter_state(_old_state: StringName, _params: Dictionary) -> void:
	sprite.play(&"crouch")


func _physics_process(_delta: float) -> void:
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.025)
	else:
		return enter_state(&"Fall")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released(&"crouch"):
		get_viewport().set_input_as_handled()
		return exit_state()
