class_name LevelManager extends Node2D


const RAT = preload("uid://do03p4467dnyq")
@onready var players: Node = $Players
@onready var spawn_points: Node = $SpawnPoints
@onready var item_spawn_timer: Timer = $ItemSpawnTimer

const PICKABLE_ITEM = preload("uid://ckl8vqyes3cml")
@onready var pickable_items: Node = $PickableItems


func _ready() -> void:
	_spawn_rats()
	
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


# we should add random spawnpoints all over the map for this
func _on_spawn_item() -> void:
	if not multiplayer.is_server():
		return
	
	var new_item = PICKABLE_ITEM.instantiate() as PickableItem
	new_item.position = Vector2(1, 1)
	new_item.name = "carrot"
	pickable_items.add_child(new_item, true)
