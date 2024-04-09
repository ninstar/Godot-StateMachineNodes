extends "jump.gd"


func entered(_previous_state: String) -> void:
	sprite.play(&"fall")


func process_physics(delta: float) -> String:
	super(delta)
	
	if player.is_on_floor():
		if player.velocity.x != 0.0:
			return "Walk"
		else:
			return "Idle"
	
	return ""
