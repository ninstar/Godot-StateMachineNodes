@icon("state_machine.svg")

class_name StateMachine extends Node


enum AutoProcess {
		NONE = 0b0,
		PROCESS = 0b1 << 0,
		PHYSICS_PROCESS = 0b1 << 1,
		INPUT = 0b1 << 2,
		SHORTCUT_INPU = 0b1 << 3,
		UNHANDLADED_INPUT = 0b1 << 4,
		UNHANDLADED_KEY_INPUT = 0b1 << 5,
		ALL = 0b111111,
	}


signal state_transitioned(old_state: StringName, new_state: StringName, params: Dictionary)


@export_range(0, 1024, 1, "or_greater", "suffix: state(s)") var history_limit: int = 1: get = get_history_limit, set = set_history_limit
@export var initial_state: StateNode: get = get_initial_state, set = set_initial_state
@export var common_node: Node: set = set_common_node, get = get_common_node

var state: StringName = &"": set = set_state, get = get_state
var history: Array[StringName] = []: set = set_history, get = get_history

var __state_table: Dictionary = {}
var __state_node: StateNode
var __state_set_only: bool = false



func enter_state(new_state: StringName, params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	var old_node: StateNode = __state_node
	var new_node: StateNode = __state_table.get(new_state, null)

	if is_instance_valid(new_node):
		__state_set_only = true
		state = new_state
		
		# Exit current state
		if is_instance_valid(old_node):
			if not skip_exit:
				old_node._exit_state(new_node.name, params)
				old_node.state_exited.emit(new_node, params)
			
			# Add to history
			history.append(old_node.name)
			if history.size() > history_limit:
				history.remove_at(0)
		
		old_node.__toggle_processes(false)
		new_node.__toggle_processes(true)
		
		# Enter new state
		if not skip_enter:
			new_node._enter_state(old_node.name, params)
			new_node.state_entered.emit(old_node, params)
		
		__state_node = new_node
		
		# Signal state transition
		if not skip_signal:
			state_transitioned.emit(old_node.name, new_node.name, params)
	else:
		push_error("StateNode \"", new_state,"\" not found. (", get_path(), ")")


func reenter_state(params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	enter_state(state, params, skip_exit, skip_enter, skip_signal)


func exit_state(params: Dictionary = {}, skip_exit: bool = false, skip_enter: bool = false, skip_signal: bool = false) -> void:
	var previou_state: StringName = get_previous_state()
	if not previou_state.is_empty():
		enter_state(previou_state, params, skip_exit, skip_enter, skip_signal)


func get_previous_state() -> StringName:
	if history.size() > 0:
		return history[history.size()-1]
	else:
		return &""


func get_state_node(state_name: StringName) -> StateNode:
	if __state_table.has(state_name):
		return __state_table[state_name] as StateNode
	else:
		return null


func get_state_list() -> Array[StringName]:
	return __state_table.keys()


func fetch_state_nodes() -> void:
	__state_table.clear()
	
	for node: Node in get_children():
		if node is StateNode:
			__state_table[node.name] = node
			
			node.__state_machine = self
			node.__common_node = common_node
			node.__toggle_processes(false)
			
			node.renamed.connect(__on_state_node_renamed.bind(node))
			node.tree_exiting.connect(__on_state_node_tree_exiting.bind(node))


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


func __on_state_node_tree_exiting(node: StateNode) -> void:
	node.__state_machine = null
	node.__common_node = null
	node.__is_current = false
	
	node.renamed.disconnect(__on_state_node_renamed)
	node.tree_exiting.disconnect(__on_state_node_tree_exiting)
	
	__state_table.erase(node.name)

#endregion
#region Virtual methods

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			fetch_state_nodes()
			
			for key: StringName in __state_table.keys():
				var node := __state_table[key] as StateNode
				node._state_machine_ready()
			
			if is_instance_valid(initial_state):
				if initial_state.get_parent() == self:
					__state_node = initial_state
					__state_set_only = true
					state = initial_state.name
					initial_state.__toggle_processes(true)
					initial_state._enter_state(&"", {})
					initial_state.state_entered.emit(&"", {})

#endregion
#region Getters & Setters

# Getters

func get_history_limit() -> int:
	return history_limit


func get_initial_state() -> StateNode:
	return initial_state


func get_common_node() -> Node:
	return common_node


func get_state() -> StringName:
	return state


func get_history() -> Array[StringName]:
	return history

# Setters

func set_history_limit(value: int) -> void:
	history_limit = value
	if history.size() > history_limit:
		history.resize(history_limit)


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
