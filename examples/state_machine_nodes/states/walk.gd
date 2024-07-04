extends "common_state.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"walk")


func _physics_process_state(_delta: float) -> String:
	if player.is_on_floor():
		var direction: float = Input.get_axis(&"walk_left", &"walk_right")
		if direction != 0.0:
			sprite.flip_h = direction < 0.0
			player.velocity.x = move_toward(player.velocity.x, SPEED * direction, SPEED * 0.05)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.05)

		if direction == 0.0 and is_zero_approx(player.velocity.x):
			return "Idle"
	else:
		return "Fall"

	return ""


func _unhandled_input_state(event: InputEvent) -> String:
	if event.is_action_pressed(&"jump"):
		get_viewport().set_input_as_handled()
		return "Jump"
	if event.is_action_pressed(&"crouch"):
		get_viewport().set_input_as_handled()
		return "Crouch"
	return ""
