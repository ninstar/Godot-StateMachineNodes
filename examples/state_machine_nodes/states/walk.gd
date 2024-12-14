extends "common_state.gd"


func _enter_state(_old_state: StringName, _params: Dictionary) -> void:
	sprite.play(&"walk")


func _physics_process(_delta: float) -> void:
	if player.is_on_floor():
		var direction: float = Input.get_axis(&"walk_left", &"walk_right")
		if direction != 0.0:
			sprite.flip_h = direction < 0.0
			player.velocity.x = move_toward(player.velocity.x, SPEED * direction, SPEED * 0.05)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.05)

		if direction == 0.0 and is_zero_approx(player.velocity.x):
			return enter_state(&"Idle")
	else:
		return enter_state(&"Fall")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"jump"):
		get_viewport().set_input_as_handled()
		return enter_state(&"Jump")
	if event.is_action_pressed(&"crouch"):
		get_viewport().set_input_as_handled()
		return enter_state(&"Crouch")
