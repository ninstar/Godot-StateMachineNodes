@icon("state_machine.svg")

class_name StateMachine extends Node


## A node used to manage and process logic on a [StateNode].
## 
## [b]StateMachine[/b] can be used to manage and process logic on different
## StateNodes at a time, at least one [StateNode] is required for this to work.
## [br][br]
## Any StateNodes that are direct children of a StateMachine will be
## automatically assigned to it once both nodes enters the [SceneTree].
## Each StateNode requires its own unique [code]name[/code].


## Emitted during the transition between two states.
signal state_transitioned(old_state: StringName, new_state: StringName, state_data: Dictionary)


## If [code]true[/code], the StateMachine ensures that only the current [StateNode]
## has its processes enabled ([method Node._process], 
## [method Node._physics_process], [method Node._input], [method Node._shortcut_input], 
## [method Node._unhandled_input] and [method Node._unhandled_key_input]).
## [br][br]
## Setting this property to [code]false[/code] disables the processes
## of all StateNodes, including the current one. This can be useful if you want
## to determine the exact point where these methods should be called in your code by using the
## [code]call_*[/code] methods ([method call_process], [method call_physics_process],
## [method call_input], [method call_shortcut_input], [method call_unhandled_input]
## and [method call_unhandled_key_input]).
## Example:
## [codeblock]
## extends CharacterBody2D
## 
## @onready var state_machine = $StateMachine
##
## func _ready()
##     state_machine.auto_process = false
##
## func _physics_process(delta):
##     # Add gravity
##     if not is_on_floor():
##         velocity += get_gravity() * delta
##     
##     # Handle movement states
##     state_machine.call_physics_process(delta)
##
##     move_and_slide()
## [/codeblock]
@export var auto_process: bool = true: get = get_auto_process, set = set_auto_process

## The maximum amount of state names the StateMachine will save in its history.
@export_range(1, 1024, 1, "or_greater", "suffix: state(s)") var history_max_size: int = 1: get = get_history_max_size, set = set_history_max_size

## The [StateNode] the StateMachine will enter once it is ready.
## [br][br]
## [b]Note:[/b] The initial StateNode (as well as other sibling states) must be a direct child of
## the StateMachine in use. Assigning a node that is outside the StateMachine or nested within
## other child node will result in unexpected behavior.
@export var initial_state: StateNode: get = get_initial_state, set = set_initial_state

## A common [Node] that can be accesed by any assigned [StateNode] via
## [method StateNode.get_common_node].
@export var common_node: Node: set = set_common_node, get = get_common_node


## The [code]name[/code] of the current [StateNode].
## Changing this value directly will trigger a state transition if a valid
## StateNode of the same name is assigned to this StateMachine, otherwise
## the value stay the same and an error is logged.
## [br][br]
## For more control over state transitions, check [method enter_state].
var state: StringName = &"": set = set_state, get = get_state

## A list with the names of previous StateNodes, from oldest to newest.
## The maximum amount of entries is determined by [member history_max_size].
var history: Array[StringName] = []: set = set_history, get = get_history


var __state_table: Dictionary[StringName, StateNode] = {}
var __state_node: StateNode
var __state_set_only: bool = false


## Changes to a different [StateNode] by [code]name[/code]
## ([param new_state]), [param state_data] can be used to transfer
## information as a [Dictionary] across states.
## [br][br]
## The order in which a state transition occurs is as follows:
## [br][br]
## [b]I. Old (Current) StateNode[/b][br]
## [b]1.[/b] Processes are disabled (if [member auto_process]
## is [code]true[/code])[br]
## [b]2.[/b] [method StateNode._exit_state] is called and [signal StateNode.state_exited]
## is emitted (if [param exit_transition] is [code]true[/code])[br]
## [br]
## [b]II. New (Target) StateNode[/b][br]
## [b]1.[/b] [method StateNode._enter_state] is called and [signal StateNode.state_entered]
## is emitted (if [param enter_transition] is [code]true[/code])[br]
## [b]2.[/b] Processes are enabled (if [member auto_process]
## is [code]true[/code])[br]
## [br]
## [b]III. StateMachine[/b][br]
## [b]1.[/b] [signal state_transitioned] is emitted (if [param signal_transition]
## is [code]true[/code])[br]
## [br]
## A state transition will only occur if [param new_state] points to
## the [code]name[/code] of a valid StateNode, otherwise the
## StateMachine will remain on its current state and
## an error will be logged.
func enter_state(new_state: StringName, state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	var old_node: StateNode = __state_node
	var new_node: StateNode = __state_table[new_state] if __state_table.has(new_state) else null

	if is_instance_valid(new_node):
		__state_set_only = true
		state = new_state
		
		new_node.__is_current = true
		
		if is_instance_valid(old_node):
			if new_node != old_node:
				old_node.__is_current = false
			
			# Disable processes
			old_node.__toggle_processes(false, auto_process)
			
			# Exit current state
			if exit_transition:
				old_node._exit_state(new_node.name, state_data)
				old_node.state_exited.emit(new_node, state_data)
			
			# Add to history
			history.append(old_node.name)
			if history.size() > history_max_size:
				history.remove_at(0)
		
		# Enter new state
		if enter_transition:
			new_node._enter_state(old_node.name, state_data)
			new_node.state_entered.emit(old_node, state_data)
		
		# Enable processes
		new_node.__toggle_processes(true, auto_process)
		
		__state_node = new_node
		
		# Signal state transition
		if signal_transition:
			state_transitioned.emit(old_node.name, new_node.name, state_data)
	else:
		push_error("StateNode '", new_state, "' not found. (", get_path(), ")")


## Re-enters the current [member state].
## Self-transition can be controlled via the optional parameters.
## (See [method enter_state].)
func reenter_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	enter_state(state, state_data, exit_transition, enter_transition, signal_transition)


## Enters the previous state if one exists in the [member history].
## (See [method enter_state].)
func exit_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	var previous_state: StringName = get_previous_state()
	if not previous_state.is_empty():
		enter_state(previous_state, state_data, exit_transition, enter_transition, signal_transition)
	else:
		push_warning("'", previous_state, "' exit state not found. (",  get_path(), ")")


## Returns the [code]name[/code] of the previous [StateNode]
## if one exists in the [member history], otherwise returns [code]&""[/code].
func get_previous_state() -> StringName:
	if history.size() > 0:
		return history[history.size()-1]
	else:
		return &""


## Returns a [StateNode] by its [code]name[/code] ([param state_name])
## if one exists, otherwise returns [code]null[/code].
func get_state_node(state_name: StringName) -> StateNode:
	if __state_table.has(state_name):
		return __state_table[state_name]
	else:
		return null


## Returns a list with the names of all available StateNodes.
func get_state_list() -> Array[StringName]:
	return __state_table.keys()


#region Manual call_* methods

## Calls [method Node._process] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_process(delta: float) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.PROCESS) == __state_node.__ProcessFlags.PROCESS
	):
		__state_node._process(delta)


## Calls [method Node._physics_process] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_physics_process(delta: float) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.PHYSICS_PROCESS) == __state_node.__ProcessFlags.PHYSICS_PROCESS
	):
		__state_node._physics_process(delta)


## Calls [method Node._input] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_input(event: InputEvent) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.INPUT) == __state_node.__ProcessFlags.INPUT
	):
		__state_node._input(event)


## Calls [method Node._shortcut_input] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_shortcut_input(event: InputEvent) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.SHORTCUT_INPUT) == __state_node.__ProcessFlags.SHORTCUT_INPUT
	):
		__state_node._shortcut_input(event)


## Calls [method Node._unhandled_input] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_unhandled_input(event: InputEvent) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.UNHANDLADED_INPUT) == __state_node.__ProcessFlags.UNHANDLADED_INPUT
	):
		__state_node._unhandled_input(event)


## Calls [method Node._unhandled_key_input] on the current [StateNode].[br][br]
## [b]Note:[/b] This is done automatically if [member auto_process]
## is [code]true[/code].
func call_unhandled_key_input(event: InputEvent) -> void:
	if(
			is_instance_valid(__state_node)
			and not auto_process
			and (__state_node.__process_flags & __state_node.__ProcessFlags.UNHANDLADED_KEY_INPUT) == __state_node.__ProcessFlags.UNHANDLADED_KEY_INPUT
	):
		__state_node._unhandled_key_input(event)

#endregion
#region Signals

func __on_state_node_renamed(node: StateNode) -> void:
	# Iterate table to find reference that matches the StateNode
	var old_node_name: StringName = &""
	for key: StringName in __state_table.keys() as Array[StringName]:
		if __state_table[key] == node:
			old_node_name = key
			break
	
	# Replace with new name
	if not old_node_name.is_empty():
		__state_table.erase(old_node_name)
		__state_table[node.name] = node
		
		if node.__is_current:
			__state_set_only = true
			state = node.name


func __on_child_entered_tree(node: Node) -> void:
	if node is StateNode and node.get_parent() == self and not __state_table.has(node.name):
		__state_table[node.name] = node as StateNode
		__state_table[node.name].__state_machine = self
		__state_table[node.name].__common_node = common_node
		__state_table[node.name].__toggle_processes(false, auto_process)
		__state_table[node.name].renamed.connect(__on_state_node_renamed.bind(__state_table[node.name]))


func __on_child_exiting_tree(node: Node) -> void:
	if node is StateNode and node.is_queued_for_deletion():
		__state_table.erase(node.name)
		__state_table[node.name].renamed.disconnect(__on_state_node_renamed)

#endregion
#region Virtual methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			child_entered_tree.connect(__on_child_entered_tree)
			child_exiting_tree.connect(__on_child_exiting_tree)
			
			for node: Node in get_children():
				if node is StateNode:
					__state_table[node.name] = node as StateNode
					__state_table[node.name].__state_machine = self
					__state_table[node.name].__common_node = common_node
					__state_table[node.name].__toggle_processes(false, auto_process)
					__state_table[node.name].renamed.connect(__on_state_node_renamed.bind(__state_table[node.name]))
			
			for key: StringName in __state_table.keys() as Array[StringName]:
				var node: StateNode = __state_table[key]
				node._state_machine_ready()
			
			if is_instance_valid(initial_state):
				if initial_state.get_parent() == self:
					__state_node = initial_state
					__state_set_only = true
					state = initial_state.name
					initial_state.__is_current = true
					initial_state.__toggle_processes(true, auto_process)
					initial_state._enter_state(&"", {})
					initial_state.state_entered.emit(&"", {})

#endregion
#region Getters & Setters

# Getters

func get_auto_process() -> bool:
	return auto_process


func get_history_max_size() -> int:
	return history_max_size


func get_initial_state() -> StateNode:
	return initial_state


func get_common_node() -> Node:
	return common_node


func get_state() -> StringName:
	return state


func get_history() -> Array[StringName]:
	return history

# Setters

func set_auto_process(value: bool) -> void:
	auto_process = value
	
	if is_instance_valid(__state_node) and __state_node.is_node_ready():
		__state_node.__toggle_processes(__state_node.is_current_state(), auto_process)


func set_history_max_size(value: int) -> void:
	history_max_size = maxi(1, value)
	if history.size() > history_max_size:
		history.resize(history_max_size)


func set_initial_state(value: StateNode) -> void:
	initial_state = value


func set_common_node(value: Node) -> void:
	common_node = value

	# Iterate state table
	for key: StringName in __state_table.keys() as Array[StringName]:
		var node: StateNode = __state_table[key]
		if is_instance_valid(node):
			node.__common_node = common_node


func set_state(value: StringName) -> void:
	if __state_set_only:
		state = value
		__state_set_only = false
	else:
		enter_state(value)


func set_history(value: Array[StringName]) -> void:
	history = value

#endregion
