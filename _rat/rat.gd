class_name RatController extends CharacterBody2D


@export var player_id: int = 1:
	set(id):
		# set input authority to the local player
		player_id = id
		%InputComponent.set_multiplayer_authority(id)
@export var player_sprite_frames: Array[SpriteFrames]
@export var sprite_frame_index: int = 0

const SPEED = 300.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var input_component: InputComponent = $InputComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var items_cnt: int = 0

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

func _ready() -> void:
	var sprite_frame = player_sprite_frames.get(sprite_frame_index)
	if sprite_frame:
		animated_sprite_2d.sprite_frames = sprite_frame
	if multiplayer.get_unique_id() == player_id:
		camera_2d.make_current()


func _physics_process(_delta: float) -> void:
	#if not multiplayer.is_server():
		#return
	
	_move_player()
	_animate_player()
	move_and_slide()


func _move_player() -> void:
	velocity = input_component.direction * SPEED

func _animate_player() -> void:
	var dir = input_component.direction
	if ANIM_MAP.has(dir) and items_cnt == 0:
		animated_sprite_2d.play(ANIM_MAP[dir])
	elif ANIM_HOLD.has(dir):
		animated_sprite_2d.play(ANIM_HOLD[dir])
	
	if dir.x != 0:
		animated_sprite_2d.flip_h = (dir == Vector2.RIGHT)


func item_pickup() -> void:
	items_cnt += 1
