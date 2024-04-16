extends "common_state.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"crouch")


func _physics_process_state(_delta: float) -> String:
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED * 0.025)
		
		if Input.is_action_just_released(&"crouch"):
			return get_state_machine().get_previous_state()
	else:
		return "Fall"
	
	return ""
