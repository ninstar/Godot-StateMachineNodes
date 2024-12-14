extends StateNode


const SPEED = 300.0


var player: CharacterBody2D
var sprite: AnimatedSprite2D


func _state_machine_ready() -> void:
	player = get_common_node()
	sprite = player.get_node(^"Sprite")
