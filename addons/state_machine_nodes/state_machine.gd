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


## Emitted when the state is changed.
signal state_changed(previous_state: String, next_state: String)


## If [code]true[/code], automates the processing of StateNodes by calling
## [method process_state] and [method physics_process_state] every frame.
## [br][br]
## Setting this property to [code]false[/code] can be useful if you want
## to manually determine when these methods should be called.
@export var auto_process: bool = true: get = get_auto_process, set = set_auto_process

## The maximum amount of state names the StateMachine will save in its history.
@export_range(0, 1024, 1, "or_greater", "suffix: state(s)") var history_limit: int = 1: get = get_history_limit, set = set_history_limit

## The [StateNode] the StateMachine will enter once it is ready.
@export var initial_state: StateNode: get = get_initial_state, set = set_initial_state

## A target [Node] that can be accesed by any assigned [StateNode] via
## [method StateNode.get_target].
@export var target_node: Node: set = set_target_node, get = get_target_node


## The [code]name[/code] of the current [StateNode] of the StateMachine.
## Changing this value directly will trigger a state transition if a valid
## StateNode of the same name is assigned to this StateMachine, otherwise
## the value stay the same and an error is logged.
## [br][br]
## For more control over state transitions, check [method change_state].
var state: String = "": set = set_state, get = get_state


## A list with names of previous StateNodes.
## The maximum amount of entries is defined by [member history_limit].
var history: Array[String] = []: set = set_history, get = get_history


var __state_table: Dictionary = {}
var __state_node: StateNode
var __silent_exit: bool = false
var __silent_enter: bool = false
var __silent_signal: bool = false


## Changes to a different [StateNode] by [code]name[/code]
## ([param new_state]).[br][br]
## The order in which a state transition occurs is as follows:[br]
## [br][b]1.[/b] On the current StateNode, [method StateNode._exit_state]
## is called and [signal StateNode.state_exited] is emitted.
## (if [param trans_exit] is [code]true[/code].)
## [br][b]2.[/b] The reference to the curent StateNode
## is changed to the new one. ([param new_state])
## [br][b]3.[/b] On the new StateNode, [method StateNode._enter_state]
## is called and [signal StateNode.state_entered] is emitted.
## (if [param trans_enter] is [code]true[/code].)
## [br][b]4.[/b] [signal state_changed] is emitted.
## (if [param trans_signal] is [code]true[/code].)
## [br][br]
## A state transition will only occur if [param new_state] points to
## the [code]name[/code] of a valid StateNode, otherwise the
## StateMachine will remain on its current state and
## an error will be logged.
func change_state(new_state: String, trans_exit: bool = true, trans_enter: bool = true, trans_signal: bool = true) -> void:
	__silent_exit = not trans_exit
	__silent_enter = not trans_enter
	__silent_signal = not trans_signal
	set_state(new_state)


## Re-enters the current [member state].
## Self-transition can be controlled via the optional parameters.
## (See [method change_state].)
func reenter_state(trans_exit: bool = true, trans_enter: bool = true, trans_signal: bool = true) -> void:
	change_state(state, trans_exit, trans_enter, trans_signal)


## Returns the [code]name[/code] of the previous [StateNode]
## if one exists in the history, otherwise returns [code]""[/code].
func get_previous_state() -> String:
	if history.size() > 0:
		return history[history.size()-1]
	return ""


## Returns a [StateNode] by its [code]name[/code] ([param state_name])
## if one exists, otherwise returns [code]null[/code].
func get_state_node(state_name: String) -> StateNode:
	if __state_table.has(state_name):
		return __state_table[state_name] as StateNode
	return null


## Returns a list with the names of all available StateNodes.
func get_state_list() -> Array[String]:
	return __state_table.keys()


## Calls [method StateNode._process_state] on the current [StateNode].
## [br][br]
## [b]Note:[/b] This method is called automatically if [member auto_process]
## is [code]true[/code].
func process_state(delta: float) -> void:
	if is_instance_valid(__state_node):
		var new_state: String = __state_node._process_state(delta)
		if not new_state.is_empty():
			set_state(new_state)


## Calls [method StateNode._physics_process_state] on the current [StateNode].
## [br][br]
## [b]Note:[/b] This method is called automatically if [member auto_process]
## is [code]true[/code].
func physics_process_state(delta: float) -> void:
	if is_instance_valid(__state_node):
		var new_state: String = __state_node._physics_process_state(delta)
		if not new_state.is_empty():
			set_state(new_state)


#region Signals

func __on_child_entered_tree(node: Node) -> void:
	if node.get_parent() == self and node is StateNode:
		__state_table[node.name] = node
		node.__state_machine = self
		node.renamed.connect(__on_state_node_renamed.bind(node))


func __on_child_exiting_tree(node: Node) -> void:
	if node.get_parent() == self and node is StateNode:
		if __state_table.has(node.name):
			__state_table.erase(node.name)
			node.__state_machine = null
			if node.renamed.is_connected(__on_state_node_renamed):
				node.renamed.disconnect(__on_state_node_renamed)


func __on_state_node_renamed(node: Node) -> void:
	# Iterate statle table to find StateNode that matches this node
	for key: String in __state_table.keys():
		# Replace entry with new node name
		if __state_table[key] == node:
			__state_table.erase(key)
			__state_table[node.name] = node
			break

#endregion
#region Virtual methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE:
			child_entered_tree.connect(__on_child_entered_tree)
			child_exiting_tree.connect(__on_child_exiting_tree)
		NOTIFICATION_READY:
			set_process(true)
			set_physics_process(true)
			for key: String in __state_table.keys():
				var node := __state_table[key] as StateNode
				node._state_machine_ready()
			if is_instance_valid(initial_state):
				if initial_state.get_parent() == self:
					__state_node = initial_state
					__state_node._enter_state("")
					__state_node.state_entered.emit()
		NOTIFICATION_PROCESS:
			if auto_process:
				process_state(get_process_delta_time())
		NOTIFICATION_PHYSICS_PROCESS:
			if auto_process:
				physics_process_state(get_physics_process_delta_time())

#endregion
#region Getters & Setters

# Getters

func get_auto_process() -> bool:
	return auto_process


func get_history_limit() -> int:
	return history_limit


func get_initial_state() -> StateNode:
	return initial_state


func get_target_node() -> Node:
	return target_node


func get_state() -> String:
	return state


func get_history() -> Array[String]:
	return history

# Setters

func set_auto_process(value: bool) -> void:
	auto_process = value


func set_history_limit(value: int) -> void:
	history_limit = value
	if history.size() > history_limit:
		history.resize(history_limit)


func set_initial_state(value: StateNode) -> void:
	initial_state = value


func set_target_node(value: Node) -> void:
	target_node = value


func set_state(value: String) -> void:
	var unmute_transitions = func():
		__silent_exit = false
		__silent_enter = false
		__silent_signal = false
	
	var previous_node: StateNode = __state_node
	var next_node: StateNode = __state_table.get(value, null)
	
	if not is_instance_valid(next_node):
		push_error("StateNode \"", value,"\" not found. (", get_path(), ")")
		unmute_transitions.call()
		return
	else:
		state = value

	# Exit current state
	if is_instance_valid(previous_node):
		if not __silent_exit:
			previous_node._exit_state(next_node.name)
			previous_node.state_exited.emit()
		
		# Add to history
		if history_limit == 1 and history.size() > 0:
			history[0] = previous_node.name
		elif history_limit >= 1:
			history.append(previous_node.name)
			if history.size() > history_limit:
				history.remove_at(0)
	
	# Enter new state
	if not __silent_enter:
		next_node._enter_state(previous_node.name)
		next_node.state_entered.emit()
	
	__state_node = next_node
	
	if not __silent_signal:
		state_changed.emit(previous_node.name, next_node.name)

	unmute_transitions.call()


func set_history(value: Array[String]) -> void:
	history = value

#endregion
