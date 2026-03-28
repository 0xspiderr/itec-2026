class_name LevelManager extends Node2D


const RAT = preload("uid://do03p4467dnyq")
@onready var players: Node = $Players
@onready var spawn_points: Node = $SpawnPoints
@onready var item_spawn_timer: Timer = $ItemSpawnTimer

const PICKABLE_ITEM = preload("uid://ckl8vqyes3cml")
@onready var pickable_items: Node = $PickableItems
@onready var pickable_spawn_points: Array[Node] = $PickableSpawnPoints.get_children()

func _ready() -> void:
	_spawn_rats()
	
	if multiplayer.is_server():
		item_spawn_timer.timeout.connect(_on_spawn_item)
		item_spawn_timer.start()


func _spawn_rats() -> void:
	if not multiplayer.is_server():
		return
	
	var spawns = spawn_points.get_children()
	
	var index: int = 0
	for id in NetworkManager.peers:
		var new_rat = RAT.instantiate() as RatController
		var spawn_point = spawns.pop_front()
		new_rat.position = spawn_point.position
		new_rat.name = str(id) 
		new_rat.player_id = id
		new_rat.sprite_frame_index = index % new_rat.player_sprite_frames.size()
		index += 1
		players.add_child(new_rat, true)


func _on_spawn_item() -> void:
	if not multiplayer.is_server():
		return
	
	var available_points = []
	for spawn_point in pickable_spawn_points:
		if not _is_position_occupied(spawn_point.position):
			available_points.append(spawn_point)
	
	if available_points.is_empty():
		print("No available spawn points!")
		return
		
	var spawn_point = available_points.pick_random()
	
	var new_item = PICKABLE_ITEM.instantiate() as PickableItem
	new_item.position = spawn_point.position
	
	# pick random item type
	var random_type = randi() % new_item.ITEM_TEXTURE_NAMES.size()
	new_item.item_type_index = random_type
	
	pickable_items.add_child(new_item, true)


func _is_position_occupied(pos: Vector2) -> bool:
	var occupation_threshold = 10.0 
	
	for item in pickable_items.get_children():
		if item is Node2D:
			if item.position.distance_to(pos) < occupation_threshold:
				return true
	return false
