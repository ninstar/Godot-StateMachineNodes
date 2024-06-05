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
## [br][br]
## The following methods can be overriden to add and extend logic:
## [method _process_state], [method _physics_process_state],
## [method _enter_state], [method _exit_state],
## [method _state_machine_ready].


var __state_machine: StateMachine


## Emitted when the state is entered.
signal state_entered()

## Emitted when the state is exited.
signal state_exited()


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] once it is ready
@warning_ignore("unused_parameter")
func _state_machine_ready() -> void:
	pass


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] when the state is entered.
## [param previous_state] is the name of the previous [b]StateNode[/b].
@warning_ignore("unused_parameter")
func _enter_state(previous_state: String) -> void:
	pass


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] when the state is exited.
## [param next_state] is the name of the next [b]StateNode[/b].
@warning_ignore("unused_parameter")
func _exit_state(next_state: String) -> void:
	pass


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] each process frame (idle) with the
## time since the last process frame as argument. ([param delta], in seconds.)
## [br][br]
## Use [param return] to specify the [code]name[/code] of the
## [b]StateNode[/b] to transition to (specifying the name of the current state
## will re-enter it), or an empty string ([code]""[/code])
## to stay in the current state for the next process frame. Example:
## [codeblock]
## func _process_state(delta):
##     # Go to "Jump" state if Up is pressed and skip the rest of this code.
##     if Input.is_action_pressed("ui_up"):
##         return "Jump"
##
##     # Stay in this state.
##     return ""
## [/codeblock]
@warning_ignore("unused_parameter")
func _process_state(delta: float) -> String:
	return ""


## [b]<OVERRIDABLE>[/b][br][br]
## Called by a [StateMachine] each physics frame with the time since
## the last physics frame as argument. ([param delta], in seconds.)
## See [method _process_state].
@warning_ignore("unused_parameter")
func _physics_process_state(delta: float) -> String:
	return ""


## Returns [code]true[/code] if the node is the current state of
## a [StateMachine].
func is_current_state() -> bool:
	if is_instance_valid(__state_machine):
		return __state_machine.__state_node == self
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")
		return false


## Returns the [code]name[/code] of the previous [StateNode] if one
## exists in the [StateMachine]'s history, otherwise returns [code]""[/code].
func get_previous_state() -> String:
	if is_instance_valid(__state_machine):
		return __state_machine.get_previous_state()
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")
	return ""


## Returns the [StateMachine] assigned to this state.
func get_state_machine() -> StateMachine:
	return __state_machine


## Returns the [member StateMachine.target_node] of the [StateMachine] assigned to this state.
func get_target() -> Node:
	if is_instance_valid(__state_machine):
		return __state_machine.target_node
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")
	return null


## Changes to a different [StateNode] by [code]name[/code]
## ([param new_state]) if a [StateMachine] is valid.
## (See [method StateMachine.change_state].)
func change_state(new_state: String, trans_exit: bool = true, trans_enter: bool = true, trans_signal: bool = true) -> void:
	if is_instance_valid(__state_machine):
		__state_machine.change_state(new_state, trans_exit, trans_enter, trans_signal)
	else:
		push_warning(get_path(), " has no valid StateMachine assigned to it.")


## Re-enters the state if the node is the current state of
## a [StateMachine]. 
## Self-transition can be controlled via the optional parameters.
## (See [method StateMachine.change_state].)
func reenter_state(trans_exit: bool = true, trans_enter: bool = true, trans_signal: bool = true) -> void:
	if is_current_state():
		__state_machine.change_state(name, trans_exit, trans_enter, trans_signal)
