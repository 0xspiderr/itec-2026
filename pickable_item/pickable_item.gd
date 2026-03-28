class_name PickableItem extends Node2D


@export var item_name: String = "default"


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return
	
	if body is RatController:
		_pickup(body)


func _pickup(body: RatController) -> void:
	if body.has_method("item_pickup"):
		body.item_pickup()
	
	queue_free()
