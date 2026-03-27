class_name RatController extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var camera_2d: Camera2D = $Camera2D
@onready var input_component: InputComponent = $InputComponent


func _ready() -> void:
	# set input authority to the local player
	%InputComponent.set_multiplayer_authority(multiplayer.get_unique_id())
	camera_2d.make_current()


func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server():
		return
	velocity = input_component.direction * SPEED
	
	move_and_slide()
