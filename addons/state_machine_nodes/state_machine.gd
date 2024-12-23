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


## Emitted during the transition between states
signal state_transitioned(old_state: StringName, new_state: StringName, state_data: Dictionary)

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


var __state_table: Dictionary = {}
var __state_node: StateNode
var __state_set_only: bool = false


## Changes to a different [StateNode] by [code]name[/code]
## ([param new_state]), [param state_data] can be used to transfer
## information as [Dictionary] between states.
## [br][br]
## The order in which a state transition occurs is as follows:[br]
## [br][b]1.[/b] On the current StateNode, [method StateNode._exit_state]
## is called and [signal StateNode.state_exited] is emitted.
## (if [param exit_transition] is [code]true[/code].)
## [br][b]2.[/b] The reference to the curent StateNode
## is changed to the new one. ([param new_state])
## [br][b]3.[/b] On the new StateNode, [method StateNode._enter_state]
## is called and [signal StateNode.state_entered] is emitted.
## (if [param enter_transition] is [code]true[/code].)
## [br][b]4.[/b] [signal state_changed] is emitted.
## (if [param signal_transition] is [code]true[/code].)
## [br][br]
## A state transition will only occur if [param new_state] points to
## the [code]name[/code] of a valid StateNode, otherwise the
## StateMachine will remain on its current state and
## an error will be logged.
func enter_state(new_state: StringName, state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	var old_node: StateNode = __state_node
	var new_node: StateNode = __state_table.get(new_state, null)

	if is_instance_valid(new_node):
		__state_set_only = true
		state = new_state
		
		new_node.__is_current = true
		
		# Exit current state
		if is_instance_valid(old_node):
			old_node.__is_current = false
			
			if exit_transition:
				old_node._exit_state(new_node.name, state_data)
				old_node.state_exited.emit(new_node, state_data)
			
			# Add to history
			history.append(old_node.name)
			if history.size() > history_max_size:
				history.remove_at(0)
		
		# Toggle processes
		old_node.__toggle_processes(false)
		new_node.__toggle_processes(true)
		
		# Enter new state
		if enter_transition:
			new_node._enter_state(old_node.name, state_data)
			new_node.state_entered.emit(old_node, state_data)
		
		__state_node = new_node
		
		# Signal state transition
		if signal_transition:
			state_transitioned.emit(old_node.name, new_node.name, state_data)
	else:
		push_error("StateNode \"", new_state,"\" not found. (", get_path(), ")")


## Re-enters the current [member state].
## Self-transition can be controlled via the optional parameters.
## (See [method enter_state].)
func reenter_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	enter_state(state, state_data, exit_transition, enter_transition, signal_transition)


## Enters the previous state if one exists in the [member history].
## (See [method enter_state].)
func exit_state(state_data: Dictionary = {}, exit_transition: bool = true, enter_transition: bool = true, signal_transition: bool = true) -> void:
	var previou_state: StringName = get_previous_state()
	if not previou_state.is_empty():
		enter_state(previou_state, state_data, exit_transition, enter_transition, signal_transition)


## Returns the [code]name[/code] of the previous [StateNode]
## if one exists in the [member history], otherwise returns [code]""[/code].
func get_previous_state() -> StringName:
	if history.size() > 0:
		return history[history.size()-1]
	else:
		return &""


## Returns a [StateNode] by its [code]name[/code] ([param state_name])
## if one exists, otherwise returns [code]null[/code].
func get_state_node(state_name: StringName) -> StateNode:
	if __state_table.has(state_name):
		return __state_table[state_name] as StateNode
	else:
		return null


## Returns a list with the names of all available StateNodes.
func get_state_list() -> Array[StringName]:
	return __state_table.keys()


#region Signals

func __on_state_node_renamed(node: StateNode) -> void:
	# Iterate table to find reference that matches the StateNode
	var old_node_name: StringName = &""
	for key: StringName in __state_table.keys():
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
		__state_table[node.name] = node
		node.__state_machine = self
		node.__common_node = common_node
		node.__toggle_processes(false)
		node.renamed.connect(__on_state_node_renamed.bind(node))


func __on_child_exiting_tree(node: Node) -> void:
	if node is StateNode and node.is_queued_for_deletion():
		__state_table.erase(node.name)
		node.renamed.disconnect(__on_state_node_renamed)

#endregion
#region Virtual methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			child_entered_tree.connect(__on_child_entered_tree)
			child_exiting_tree.connect(__on_child_exiting_tree)
			
			for node: Node in get_children():
				if node is StateNode:
					__state_table[node.name] = node
					node.__state_machine = self
					node.__common_node = common_node
					node.__toggle_processes(false)
					node.renamed.connect(__on_state_node_renamed.bind(node))
			
			for key: StringName in __state_table.keys():
				var node := __state_table[key] as StateNode
				node._state_machine_ready()
			
			if is_instance_valid(initial_state):
				if initial_state.get_parent() == self:
					__state_node = initial_state
					__state_set_only = true
					state = initial_state.name
					initial_state.__is_current = true
					initial_state.__toggle_processes(true)
					initial_state._enter_state(&"", {})
					initial_state.state_entered.emit(&"", {})

#endregion
#region Getters & Setters

# Getters

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

func set_history_max_size(value: int) -> void:
	history_max_size = maxi(1, value)
	if history.size() > history_max_size:
		history.resize(history_max_size)


func set_initial_state(value: StateNode) -> void:
	initial_state = value


func set_common_node(value: Node) -> void:
	common_node = value

	# Iterate state table
	for key: StringName in __state_table.keys():
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
