extends "jump.gd"


func _enter_state(_previous_state: String) -> void:
	sprite.play(&"fall")


func _physics_process_state(delta: float) -> String:
	super(delta)
	
	if player.is_on_floor():
		if player.velocity.x != 0.0:
			return "Walk"
		else:
			return "Idle"
	
	return ""
