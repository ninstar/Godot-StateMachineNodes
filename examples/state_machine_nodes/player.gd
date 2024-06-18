extends CharacterBody2D


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	load_input_map()
	$State.text = state_machine.initial_state.name


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * 2.0 * delta
	
	# Uncomment the line below if you've set the 'StateMachine.auto_process' to 'false'!
	# state_machine.physics_process_state(delta)
	
	move_and_slide()


func _on_state_machine_state_changed(_previous_state: String, new_state: String) -> void:
	$State.text = new_state


func load_input_map() -> void:
	var add_keys = func(action: StringName, keycodes: Array) -> void:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in keycodes:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action, event)
	var add_pads = func(action: StringName, button_indexes: Array) -> void:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for button_index in button_indexes:
			var event := InputEventJoypadButton.new()
			event.button_index = button_index
			InputMap.action_add_event(action, event)
		
	# Jump
	add_keys.call(&"jump", [KEY_SPACE, KEY_UP, KEY_W])
	add_pads.call(&"jump", [JOY_BUTTON_DPAD_UP, JOY_BUTTON_A, JOY_BUTTON_B])
	
	# Crouch
	add_keys.call(&"crouch", [KEY_DOWN, KEY_S])
	add_pads.call(&"crouch", [JOY_BUTTON_DPAD_DOWN])
	
	# Walk (Left)
	add_keys.call(&"walk_left", [KEY_LEFT, KEY_A])
	add_pads.call(&"walk_left", [JOY_BUTTON_DPAD_LEFT])

	# Walk (Right)
	add_keys.call(&"walk_right", [KEY_RIGHT, KEY_D])
	add_pads.call(&"walk_right", [JOY_BUTTON_DPAD_RIGHT])
