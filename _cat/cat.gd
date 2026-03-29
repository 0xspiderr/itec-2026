class_name Cat extends CharacterBody2D

const SPEED = 350.0
var direction: Vector2 = Vector2.ZERO
var is_retreating: bool = false
var is_exploding: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var sync_anim: String = "run":
	set(value):
		sync_anim = value
		if animated_sprite:
			animated_sprite.play(sync_anim)

@export var sync_flip: bool = false:
	set(value):
		sync_flip = value
		if animated_sprite:
			animated_sprite.flip_h = sync_flip

func _ready() -> void:
	if animated_sprite:
		animated_sprite.play(sync_anim)
		animated_sprite.flip_h = sync_flip

func setup_direction(target_pos: Vector2) -> void:
	direction = global_position.direction_to(target_pos)
	sync_flip = (direction.x < 0)
	sync_anim = "run"

func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server() or is_exploding:
		return

	velocity = direction * SPEED
	move_and_slide()
	_check_collisions()

func _check_collisions() -> void:
	var areas = hitbox.get_overlapping_areas()
	for area in areas:
		var target = area.get_parent()
		
		if target is Soup and not is_retreating:
			_explode(target)
			audio_stream_player_2d.play(0.8)
			return
		elif target is RatController and not is_retreating:
			_retreat()
			audio_stream_player_2d.play(0.8)
			return

func _explode(pot: Soup) -> void:
	is_exploding = true
	pot.server_receive_cat_explosion() 
	
	sync_anim = "explode"
	
	await animated_sprite.animation_finished
	if is_inside_tree():
		queue_free()

func _retreat() -> void:
	is_retreating = true
	direction = -direction 
	sync_flip = (direction.x < 0) # Automatically flips the sprite for everyone
	
	await get_tree().create_timer(2.5).timeout
	if is_inside_tree():
		queue_free()
