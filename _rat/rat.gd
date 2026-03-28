class_name RatController extends CharacterBody2D


@export var player_id: int = 1:
	set(id):
		# set input authority to the local player
		player_id = id
		%InputComponent.set_multiplayer_authority(id)
@export var player_sprite_frames: Array[SpriteFrames]
@export var sprite_frame_index: int = 0
@onready var interaction_area: Area2D = $InteractionArea
@onready var item_tex: TextureRect = $CanvasLayer/MarginContainer/ItemSlot/ItemTex

const SPEED = 300.0

# showns only for local player
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var camera_2d: Camera2D = $Camera2D
@onready var input_component: InputComponent = $InputComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


const ANIM_MAP = {
	Vector2.ZERO: &"idle",
	Vector2.LEFT: &"walk_left",
	Vector2.RIGHT: &"walk_left", # this will be flipped
	Vector2.UP: &"walk_up",
	Vector2.DOWN: &"walk_down"
}
const ANIM_HOLD = {
	Vector2.ZERO: &"idle_hold",
	Vector2.LEFT: &"walk_left_hold",
	Vector2.RIGHT: &"walk_left_hold",
	Vector2.UP: &"walk_up_hold",
	Vector2.DOWN: &"walk_down_hold"
}

var is_picking_up: bool = false
@export var picked_items: Dictionary = {}
@export var item_textures: Dictionary[String, Texture2D] = {}


func _ready() -> void:
	var sprite_frame = player_sprite_frames.get(sprite_frame_index)
	if multiplayer.get_unique_id() != player_id:
		canvas_layer.hide()
	else:
		item_tex.texture = null
	
	if sprite_frame:
		animated_sprite_2d.sprite_frames = sprite_frame
	if multiplayer.get_unique_id() == player_id:
		camera_2d.make_current()
	input_component.pickup_pressed.connect(_on_pickup_pressed)


func _physics_process(_delta: float) -> void:
	#if not multiplayer.is_server():
		#return
	if is_picking_up:
		return
	
	_move_player()
	_animate_player()
	move_and_slide()


func _move_player() -> void:
	velocity = input_component.direction * SPEED

func _animate_player() -> void:
	var dir = input_component.direction
	
	if dir == Vector2.ZERO:
		if picked_items.is_empty():
			animated_sprite_2d.play(ANIM_MAP[Vector2.ZERO])
		else:
			animated_sprite_2d.play(ANIM_HOLD[Vector2.ZERO])
		return

	var anim_key = Vector2.ZERO
	if abs(dir.x) > 0.01:
		anim_key = Vector2.LEFT
		animated_sprite_2d.flip_h = (dir.x > 0)
	else:
		animated_sprite_2d.flip_h = false
		if dir.y < 0:
			anim_key = Vector2.UP
		elif dir.y > 0:
			anim_key = Vector2.DOWN
	
	if picked_items.is_empty():
		if ANIM_MAP.has(anim_key):
			animated_sprite_2d.play(ANIM_MAP[anim_key])
	else:
		if ANIM_HOLD.has(anim_key):
			animated_sprite_2d.play(ANIM_HOLD[anim_key])


func _on_pickup_pressed() -> void:
	request_pickup.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func request_pickup():
	if not multiplayer.is_server(): return
	
	var areas = interaction_area.get_overlapping_areas()
	
	for area in areas:
		var item = area.get_parent()
		if item is PickableItem:
			if not picked_items.is_empty():
				print("inventory full")
				return
			picked_items[item.item_name] = 1
			item.server_confirm_pickup(self)
			# call for host locally
			if player_id == multiplayer.get_unique_id():
				_update_item_texture(item.item_name)
			else:
				_update_item_texture.rpc_id(player_id, item.item_name)
			print(picked_items)
			return 
		elif item is Soup:
			if not picked_items.is_empty():
				var send_item = picked_items.keys()[0]
				picked_items.erase(send_item)
				print(picked_items)
				item.server_receive_ingredient(self, send_item)
				if player_id == multiplayer.get_unique_id():
					_update_item_texture("")
				else:
					_update_item_texture.rpc_id(player_id, "")
				return

func item_pickup():
	_play_pickup_effects.rpc()


@rpc("authority", "call_local", "reliable")
func _play_pickup_effects():
	is_picking_up = true
	animated_sprite_2d.play("pickup") 
	print("PICKED UP")
	await animated_sprite_2d.animation_finished
	is_picking_up = false

@rpc("authority", "call_local", "reliable")
func _update_item_texture(new_item: String) -> void:
	if not item_tex: return
	
	if new_item == "" or not item_textures.has(new_item):
		item_tex.texture = null
	else:
		item_tex.texture = item_textures[new_item]
	
	item_tex.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(item_tex, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
