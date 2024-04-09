extends VBoxContainer


@export var state_machine: StateMachine

@onready var list: TextEdit = $Panel/List
@onready var count: Label = $Count


func _ready() -> void:
	if is_instance_valid(state_machine):
		state_machine.state_changed.connect(update_history.unbind(2))
		update_history()


func update_history() -> void:
	var reversed_history: Array[String] = state_machine.history.duplicate()
	reversed_history.reverse()
	
	list.text = "\n".join(reversed_history)
	count.text = "History %s/%s" % [state_machine.get_history().size(), state_machine.history_limit]
