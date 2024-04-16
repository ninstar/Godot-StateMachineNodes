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
		elif Input.is_action_just_pressed(&"jump"):
			return "Jump"
		elif Input.is_action_just_pressed(&"crouch"):
			return "Crouch"
	else:
		return "Fall"
	
	return ""
