class_name Cat extends CharacterBody2D

const SPEED = 350.0
var direction: Vector2 = Vector2.ZERO
var is_retreating: bool = false
var is_exploding: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

func setup_direction(target_pos: Vector2) -> void:
	# Calculates a perfect straight line to the pot
	direction = global_position.direction_to(target_pos)
	_update_visuals.rpc(direction.x < 0)

@rpc("authority", "call_local", "reliable")
func _update_visuals(flip: bool) -> void:
	animated_sprite.flip_h = flip
	animated_sprite.play("run")

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
			return
		elif target is RatController and not is_retreating:
			_retreat()
			return

func _explode(pot: Soup) -> void:
	is_exploding = true
	pot.server_receive_cat_explosion()
	_play_explode_animation.rpc()

func _retreat() -> void:
	is_retreating = true
	direction = -direction
	_update_visuals.rpc(direction.x < 0)
	
	await get_tree().create_timer(4.0).timeout
	if is_inside_tree():
		queue_free()

@rpc("authority", "call_local", "reliable")
func _play_explode_animation() -> void:
	is_exploding = true
	animated_sprite.play("explode")
	await animated_sprite.animation_finished
	
	if multiplayer.is_server() and is_inside_tree():
		queue_free()
