class_name RatController extends CharacterBody2D


@export var player_id: int = 1:
	set(id):
		# set input authority to the local player
		player_id = id
		%InputComponent.set_multiplayer_authority(id)

const SPEED = 300.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var input_component: InputComponent = $InputComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		camera_2d.make_current()


func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	_move_player()
	move_and_slide()


func _move_player() -> void:
	if input_component.direction == Vector2.ZERO:
		animated_sprite_2d.play(&"idle")
	elif input_component.direction == Vector2.LEFT:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(&"move_left")
	elif input_component.direction == Vector2.RIGHT:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play(&"move_left")
	elif input_component.direction == Vector2.DOWN:
		animated_sprite_2d.play(&"move_down")
	elif input_component.direction == Vector2.UP:
		animated_sprite_2d.play(&"move_up")
	
	velocity = input_component.direction * SPEED
