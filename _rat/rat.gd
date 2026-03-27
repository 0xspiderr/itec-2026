class_name RatController extends CharacterBody2D


@export var player_id: int = 1:
	set(id):
		# set input authority to the local player
		player_id = id
		%InputComponent.set_multiplayer_authority(id)

const SPEED = 300.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var input_component: InputComponent = $InputComponent


func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		camera_2d.make_current()


func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	velocity = input_component.direction * SPEED
	
	move_and_slide()
