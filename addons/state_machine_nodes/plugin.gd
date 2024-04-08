@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("StateMachine", "Node", preload("state_machine.gd"), preload("state_machine.svg"))
	add_custom_type("StateNode", "Node", preload("state_node.gd"), preload("state_node.svg"))


func _exit_tree():
	remove_custom_type("StateMachine")
	remove_custom_type("StateNode")
