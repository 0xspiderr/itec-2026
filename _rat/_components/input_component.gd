class_name InputComponent extends Node


signal pickup_pressed()
@export var direction: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	direction = Input.get_vector("left", "right", "up", "down")
	if event.is_action_pressed("pickup"):
		pickup_pressed.emit()
