extends VBoxContainer


@export var state_machine: StateMachine

@onready var list: TextEdit = $Panel/List
@onready var count: Label = $Count


func _ready() -> void:
	if is_instance_valid(state_machine):
		state_machine.state_transitioned.connect(update_history.unbind(3))
		update_history()


func update_history() -> void:
	var reversed_history: Array[StringName] = state_machine.history.duplicate()
	reversed_history.reverse()
	
	list.text = "\n".join(reversed_history)
	count.text = "History %s/%s" % [state_machine.get_history().size(), state_machine.history_max_size]
