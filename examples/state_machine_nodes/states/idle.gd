extends "common_state.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"idle")


func _physics_process_state(_delta: float) -> String:
	if player.is_on_floor():
		if Input.get_axis(&"walk_left", &"walk_right") != 0.0:
			return "Walk"
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
