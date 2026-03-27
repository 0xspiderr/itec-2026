class_name InputComponent extends Node


@export var direction: Vector2 = Vector2.ZERO


func _input(_event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	
	direction = Input.get_vector("left", "right", "up", "down")
