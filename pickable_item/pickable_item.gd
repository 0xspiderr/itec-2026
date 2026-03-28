class_name PickableItem extends Node2D


@export var item_textures: Array[Texture2D]
const ITEM_TEXTURE_NAMES = [
	"winter berries",
	"dried barley",
	"mushroom",
	"wild leeks",
	"turnip",
	"meat"
]

@export var item_type_index: int = 0:
	set(index):
		item_type_index = index


@export var item_name: String = "default"
@onready var sprite_2d: Sprite2D = $Sprite2D

const TWEEN_TIME_SPAWN: float = 1.0


func _ready() -> void:
	_apply_item_type()
	_play_spawn_animation()


func _apply_item_type() -> void:
	# Set the visuals and the name based on the index
	sprite_2d.texture = item_textures[item_type_index]
	item_name = ITEM_TEXTURE_NAMES[item_type_index]


func server_confirm_pickup(picker: RatController) -> void:
	if not multiplayer.is_server(): return
	
	if picker.has_method("item_pickup"):
		picker.item_pickup()
	
	_squish_and_die.rpc()


func _play_spawn_animation() -> void:
	scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), TWEEN_TIME_SPAWN)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	_start_hover_animation()


func _start_hover_animation() -> void:
	var hover_tween = create_tween().set_loops()
	var target_pos = position + Vector2(0, -10) # hover 10 pixels up
	
	hover_tween.tween_property(self, "position", target_pos, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	hover_tween.tween_property(self, "position", position, 1.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)


@rpc("any_peer", "call_local", "reliable")
func _squish_and_die() -> void:
	# disable collision for no double picking
	if has_node("Area2D"):
		$Area2D.set_deferred("monitoring", false)
		$Area2D.set_deferred("monitorable", false)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2.5, 0.1), 0.15)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	# free only on the server as this item is watched by a multiplayer spawner
	if multiplayer.is_server():
		queue_free()
