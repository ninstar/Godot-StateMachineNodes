extends "common_state.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"idle")


func _physics_process_state(_delta: float) -> String:
	if player.is_on_floor():
		if Input.get_axis(&"walk_left", &"walk_right") != 0.0:
			return "Walk"
		elif Input.is_action_just_pressed(&"jump"):
			return "Jump"
		elif Input.is_action_just_pressed(&"crouch"):
			return "Crouch"
	else:
		return "Fall"
	
	return ""
