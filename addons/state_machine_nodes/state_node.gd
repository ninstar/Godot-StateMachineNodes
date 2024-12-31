@icon("state_node.svg")

class_name StateNode extends Node


## A node that functions as a state for a [StateMachine].
##
## StateNodes can be used to encapsulate and organize logic that is
## processed by a parent StateMachine when needed.
## [br][br]
## Any StateNodes that are direct children of a StateMachine will be
## automatically assigned to it once both nodes enters the [SceneTree].
## Each StateNode requires its own unique [code]name[/code].


## Emitted when the state is entered.
signal state_entered(old_state: StringName, state_data: Dictionary)

## Emitted when the state is exited.
signal state_exited(new_state: StringName, state_data: Dictionary)


enum __ProcessFlags {
		PROCESS = 0b1 << 0,
		PHYSICS_PROCESS = 0b1 << 1,
		INPUT = 0b1 << 2,
		SHORTCUT_INPUT = 0b1 << 3,
		UNHANDLADED_INPUT = 0b1 << 4,
		UNHANDLADED_KEY_INPUT = 0b1 << 5,
	}


var __state_machine: StateMachine = null
var __common_node: Node = null
var __is_current: bool = false
var __process_flags: int = 0


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] once it is ready
@warning_ignore("unused_parameter")
func _state_machine_ready() -> void:
	pass


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] when the state is entered.
@warning_ignore("unused_parameter")
func _enter_state(old_state: StringName, state_data: Dictionary) -> void:
	pass


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] when the state is exited.
@warning_ignore("unused_parameter")
func _exit_state(new_state: StringName, state_data: Dictionary) -> void:
	pass


## Returns [code]true[/code] if the node is the current state of
## a [StateMachine].
func is_current_state() -> bool:
	return __is_current


## Returns the [code]name[/code] of the previous [StateNode] if one
## exists in the [member StateMachine.history], otherwise returns [code]&""[/code].
func get_previous_state() -> StringName:
	if is_instance_valid(__state_machine):
		return __state_machine.get_previous_state()
	else:
		push_warning("'", name, "' has no valid StateMachine assigned to it. (", get_path(), ")")
		return &""


## Returns the [StateMachine] assigned to this state.
func get_state_machine() -> StateMachine:
	return __state_machine


## Returns the [member StateMachine.common_node] of the [StateMachine] assigned to this state.
func get_common_node() -> Node:
	return __common_node


## Changes to a different [StateNode] by [code]name[/code]
## ([param new_state]) if a [StateMachine] is valid.
## (See [method StateMachine.enter_state].)
func enter_state(new_state: StringName, state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	if is_instance_valid(__state_machine):
		if is_current_state():
			__state_machine.enter_state(new_state, state_data, exit_transition, enter_transition, signal_transition)
		else:
			push_warning("'", name, "' is not set as the current state of a StateMachine. (", get_path(), ")")
	else:
		push_warning("'", name, "' has no valid StateMachine assigned to it. (", get_path(), ")")


## Re-enters the state if the node is the current one. 
## Self-transition can be controlled via the optional parameters.
## (See [method StateMachine.enter_state].)
func reenter_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	if is_instance_valid(__state_machine):
		if is_current_state():
			__state_machine.enter_state(name, state_data, exit_transition, enter_transition, signal_transition)
		else:
			push_warning("'", name, "' is not set as the current state of a StateMachine. (", get_path(), ")")
	else:
		push_warning("'", name, "' has no valid StateMachine assigned to it. (", get_path(), ")")


## Enters the previous state if one exists in the [member StateMachine.history].
## (See [method StateMachine.enter_state].)
func exit_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	if is_instance_valid(__state_machine):
		if is_current_state():
			var previous_state: StringName = get_previous_state()
			if not previous_state.is_empty():
				enter_state(previous_state, state_data, exit_transition, enter_transition, signal_transition)
			else:
				push_warning("'", previous_state, "' exit state not found. (",  get_path(), ")")
		else:
			push_warning("'", name, "' is not set as the current state of a StateMachine. (", get_path(), ")")
	else:
		push_warning("'", name, "' has no valid StateMachine assigned to it. (", get_path(), ")")


func __toggle_processes(enabled: bool, auto_set:  bool) -> void:
	var __is_enabled: bool = enabled and auto_set
	
	if (__process_flags & __ProcessFlags.PROCESS) == __ProcessFlags.PROCESS:
		set_process(__is_enabled)
	if (__process_flags & __ProcessFlags.PHYSICS_PROCESS) == __ProcessFlags.PHYSICS_PROCESS:
		set_physics_process(__is_enabled)
	if (__process_flags & __ProcessFlags.INPUT) == __ProcessFlags.INPUT:
		set_process_input(__is_enabled)
	if (__process_flags & __ProcessFlags.SHORTCUT_INPUT) == __ProcessFlags.SHORTCUT_INPUT:
		set_process_shortcut_input(__is_enabled)
	if (__process_flags & __ProcessFlags.UNHANDLADED_INPUT) == __ProcessFlags.UNHANDLADED_INPUT:
		set_process_unhandled_input(__is_enabled)
	if (__process_flags & __ProcessFlags.UNHANDLADED_KEY_INPUT) == __ProcessFlags.UNHANDLADED_KEY_INPUT:
		set_process_unhandled_key_input(__is_enabled)


#region Virtual Methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			# Determine what processes have been overridden
			if is_processing():
				__process_flags = __process_flags | __ProcessFlags.PROCESS
			if is_physics_processing():
				__process_flags = __process_flags | __ProcessFlags.PHYSICS_PROCESS
			if is_processing_input():
				__process_flags = __process_flags | __ProcessFlags.INPUT
			if is_processing_shortcut_input():
				__process_flags = __process_flags | __ProcessFlags.SHORTCUT_INPUT
			if is_processing_unhandled_input():
				__process_flags = __process_flags | __ProcessFlags.UNHANDLADED_INPUT
			if is_processing_unhandled_key_input():
				__process_flags = __process_flags | __ProcessFlags.UNHANDLADED_KEY_INPUT

#endregion
