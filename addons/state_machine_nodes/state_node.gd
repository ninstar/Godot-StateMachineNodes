# Copyright (c) 2024 NinStar
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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


var _state_machine: StateMachine


## Called by a [StateMachine] once it is ready.
func state_machine_ready() -> void:
	pass


## Called by a [StateMachine] when the state is entered.
## [param previous_state] is the name of the previous [b]StateNode[/b].
@warning_ignore("unused_parameter")
func entered(previous_state: String) -> void:
	pass


## Called by a [StateMachine] when the state is exited.
## [param next_state] is the name of the next [b]StateNode[/b].
@warning_ignore("unused_parameter")
func exited(next_state: String) -> void:
	pass


## Called by a [StateMachine] each process frame (idle) with the
## time since the last process frame as argument ([param delta], in seconds).
## [br][br]
## Use [param return] to specify the [code]name[/code] of the
## [b]StateNode[/b] to transition to or an empty string ([code]""[/code])
## to stay in the current state for the next process frame. Example:
## [codeblock]
## func process_frame(delta):
##     # Go to "Jump" state if Up is pressed and skip the rest of this code.
##     if Input.is_action_pressed("ui_up"):
##         return "Jump"
##
##     # Stay in this state.
##     return ""
## [/codeblock]
@warning_ignore("unused_parameter")
func process_frame(delta: float) -> String:
	return ""


## Called by a [StateMachine] each physics frame with the time since
## the last physics frame as argument ([param delta], in seconds).
## (See [method process_frame]).
@warning_ignore("unused_parameter")
func process_physics(delta: float) -> String:
	return ""


## Called by a [StateMachine] when there is an input event.
## Equivalent to [method Node._input].
## (See [method process_frame]).
@warning_ignore("unused_parameter")
func process_input(event: InputEvent) -> String:
	return ""


## Called by a [StateMachine] when an [InputEvent] hasn't been consumed by
## [method Node._input] or any GUI [Control] item.
## Equivalent to [method Node._unhandled_input].
## (See [method process_frame]).
@warning_ignore("unused_parameter")
func process_unhandled_input(event: InputEvent) -> String:
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
