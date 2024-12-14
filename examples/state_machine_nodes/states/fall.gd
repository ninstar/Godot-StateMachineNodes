extends "jump.gd"


func _enter_state(_old_state: StringName, _params: Dictionary) -> void:
	sprite.play(&"fall")


func _physics_process(delta: float) -> void:
	super(delta)
	
	if player.is_on_floor():
		if player.velocity.x != 0.0:
			return enter_state(&"Walk")
		else:
			return enter_state(&"Idle")
