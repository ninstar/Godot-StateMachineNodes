extends "common_state.gd"


const JUMP_VELOCITY = -800.0


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"jump")
	player.velocity.y = JUMP_VELOCITY


func _physics_process_state(_delta: float) -> String:
	var direction: float = Input.get_axis(&"walk_left", &"walk_right")
	if direction != 0.0:
		sprite.flip_h = direction < 0.0
		player.velocity.x = move_toward(player.velocity.x, SPEED * direction, SPEED * 0.075)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.01)
	
	if name == "Jump":
		var minimum: float = JUMP_VELOCITY * 0.5
		if Input.is_action_just_released(&"jump") and player.velocity.y < minimum:
			player.velocity.y = minimum
		
		if player.velocity.y >= 0.0:
			return "Fall"
	
	return ""
