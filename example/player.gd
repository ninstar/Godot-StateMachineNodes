extends CharacterBody2D


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	$State.text = state_machine.initial_state.name


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * 2.0 * delta
	
	# Uncomment the line below if you've set the 'StateMachine.automated' to 'false'!
	#state_machine.process_physics(delta)
	
	move_and_slide()


func _on_state_machine_state_changed(_previous_state: String, new_state: String) -> void:
	$State.text = new_state
