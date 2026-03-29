class_name ButuragaRelaxatoare extends CharacterBody2D


const SPEED = 200.0

var holder_1: RatController = null
var holder_2: RatController = null

@onready var left_grab: Marker2D = $LeftGrab
@onready var right_grab: Marker2D = $RightGrab
@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _physics_process(_delta: float) -> void:
	if not multiplayer.is_server(): return

	if holder_1 != null and holder_2 != null:
		var dir1 = holder_1.input_component.direction
		var dir2 = holder_2.input_component.direction

		if dir1 == dir2 and dir1 != Vector2.ZERO:
			velocity = dir1 * SPEED
		else:
			velocity = Vector2.ZERO
		
		move_and_slide()

		# force the rats to stay attached to the grab points as the log moves
		holder_1.global_position = left_grab.global_position
		holder_2.global_position = right_grab.global_position
	else:
		velocity = Vector2.ZERO
		move_and_slide() 

func server_try_interact(player: RatController) -> void:
	if not multiplayer.is_server(): return

	if player == holder_1 or player == holder_2:
		var overlapping_areas = area_2d.get_overlapping_areas()
		var burned_in_pot = false
		for area in overlapping_areas:
			var target = area.get_parent()
			if target is Soup:
				target.server_receive_log()
				burned_in_pot = true
				break
		_server_drop_all()
		if burned_in_pot:
			queue_free()
		return

	var dist_to_left = player.global_position.distance_to(left_grab.global_position)
	var dist_to_right = player.global_position.distance_to(right_grab.global_position)

	if dist_to_left < dist_to_right:
		if holder_1 == null:
			holder_1 = player
			_set_rat_carry_state(holder_1, true)
	else:
		if holder_2 == null:
			holder_2 = player
			_set_rat_carry_state(holder_2, true)

func _server_drop_all() -> void:
	audio_stream_player_2d.play()
	if holder_1 != null:
		_set_rat_carry_state(holder_1, false)
		holder_1 = null
	if holder_2 != null:
		_set_rat_carry_state(holder_2, false)
		holder_2 = null

func _set_rat_carry_state(rat: RatController, state: bool) -> void:
	rat.is_carrying_heavy = state
	rat.set_heavy_carry_state.rpc(state)
	if state == true:
		rat.current_buturuga = self
	else:
		rat.current_buturuga = null
