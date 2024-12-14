@icon("state_node.svg")

class_name StateNode extends Node


signal state_entered(old_state: StringName, params: Dictionary)
signal state_exited(new_state: StringName, params: Dictionary)


enum __Process {
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
var __process: int = 0

@export var auto_set_processes: bool = true: get = get_auto_set_processes, set = set_auto_set_processes


@warning_ignore("unused_parameter")
func _state_machine_ready() -> void:
	pass


@warning_ignore("unused_parameter")
func _enter_state(old_state: StringName, params: Dictionary) -> void:
	pass


@warning_ignore("unused_parameter")
func _exit_state(new_state: StringName, params: Dictionary) -> void:
	pass


func is_current_state() -> bool:
	return __is_current


func get_previous_state() -> StringName:
	if is_instance_valid(__state_machine):
		return __state_machine.get_previous_state()
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")
		return ""


func get_state_machine() -> StateMachine:
	return __state_machine


func get_common_node() -> Node:
	return __common_node


func enter_state(new_state: StringName, params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	if is_instance_valid(__state_machine):
		__state_machine.enter_state(new_state, params, skip_exit, skip_enter, skip_signal)
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")


func reenter_state(params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	if is_current_state():
		__state_machine.enter_state(name, params, skip_exit, skip_enter, skip_signal)


func exit_state(params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	var previou_state: StringName = get_previous_state()
	if not previou_state.is_empty():
		enter_state(previou_state, params, skip_exit, skip_enter, skip_signal)


func __toggle_processes(enabled: bool) -> void:
	if (__process & __Process.PROCESS) == __Process.PROCESS:
		set_process(enabled)
	if (__process & __Process.PHYSICS_PROCESS) == __Process.PHYSICS_PROCESS:
		set_physics_process(enabled)
	if (__process & __Process.INPUT) == __Process.INPUT:
		set_process_input(enabled)
	if (__process & __Process.SHORTCUT_INPUT) == __Process.SHORTCUT_INPUT:
		set_process_shortcut_input(enabled)
	if (__process & __Process.UNHANDLADED_INPUT) == __Process.UNHANDLADED_INPUT:
		set_process_unhandled_input(enabled)
	if (__process & __Process.UNHANDLADED_KEY_INPUT) == __Process.UNHANDLADED_KEY_INPUT:
		set_process_unhandled_key_input(enabled)


#region Virtual Methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			if is_processing():
				__process = __process | __Process.PROCESS
			if is_physics_processing():
				__process = __process | __Process.PHYSICS_PROCESS
			if is_processing_input():
				__process = __process | __Process.INPUT
			if is_processing_shortcut_input():
				__process = __process | __Process.SHORTCUT_INPUT
			if is_processing_unhandled_input():
				__process = __process | __Process.UNHANDLADED_INPUT
			if is_processing_unhandled_key_input():
				__process = __process | __Process.UNHANDLADED_KEY_INPUT

#endregion
#region Getters & Setters

# Getters

func get_auto_set_processes() -> bool:
	return auto_set_processes

# Setters

func set_auto_set_processes(value: bool) -> void:
	auto_set_processes = value

#endregion
