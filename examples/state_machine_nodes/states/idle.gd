extends "common_state.gd"


func _enter_state(_old_state: StringName, _params: Dictionary) -> void:
	sprite.play(&"idle")


func _physics_process(_delta: float) -> void:
	if player.is_on_floor():
		if Input.get_axis(&"walk_left", &"walk_right") != 0.0:
			return enter_state(&"Walk")
	else:
		return enter_state(&"Fall")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"jump"):
		return enter_state(&"Jump")
	if event.is_action_pressed(&"crouch"):
		return enter_state(&"Crouch")
