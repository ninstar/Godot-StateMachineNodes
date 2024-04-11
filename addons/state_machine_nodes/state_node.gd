@icon("state_node.svg")

class_name StateNode extends Node


## A node that functions as a state for a [StateMachine].
##
## StateNodes can be used to encapsulate and organize complex logic,
## they are managed and ran by StateMachines.
## [br][br]
## Any StateNodes that are direct children of a StateMachine will be
## automatically assigned to it once it enters the [SceneTree].
## Each StateNode requires its own unique [code]name[/code].
## [br][br]
## The following methods can be overriden to add and extend logic:
## [method _process_state], [method _physics_process_state],
## [method _enter_state], [method _exit_state],
## [method _state_machine_ready].


var _state_machine: StateMachine


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
## time since the last process frame as argument ([param delta], in seconds).
## [br][br]
## Use [param return] to specify the [code]name[/code] of the
## [b]StateNode[/b] to transition to or an empty string ([code]""[/code])
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
## the last physics frame as argument ([param delta], in seconds).
## (See [method _process_state]).
@warning_ignore("unused_parameter")
func _physics_process_state(delta: float) -> String:
	return ""


## Returns [code]true[/code] if the node is the current state of
## a [StateMachine].
func is_current_state() -> bool:
	if is_instance_valid(_state_machine):
		return _state_machine._state_node == self
	else:
		return false


## Returns the [code]name[/code] of the previous [StateNode] if one
## exists in the [StateMachine]'s history, otherwise returns [code]""[/code].
func get_previous_state() -> String:
	if is_instance_valid(_state_machine):
		if _state_machine.history.size() > 0:
			return _state_machine.history[_state_machine.history.size()-1]
	return ""


## Returns the [StateMachine] assigned to this state.
func get_state_machine() -> StateMachine:
	return _state_machine


## Returns the [member StateMachine.target_node] of the [StateMachine] assigned to this state.
func get_target() -> Node:
	if is_instance_valid(_state_machine):
		return _state_machine.target_node
	return null
