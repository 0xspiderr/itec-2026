class_name LevelManager extends Node2D


const RAT = preload("uid://do03p4467dnyq")
@onready var players: Node = %Players
@onready var spawn_points: Node = $SpawnPoints
@onready var item_spawn_timer: Timer = $ItemSpawnTimer
@onready var buturuga_spawn_timer: Timer = $ButurugaSpawnTimer

const BUTURUGA_RELAXATOARE = preload("uid://cw1h70len88x6")
const PICKABLE_ITEM = preload("uid://ckl8vqyes3cml")
@onready var pickable_items: Node = $PickableItems
@onready var buturugi: Node = $Buturugi
@onready var pickable_spawn_points: Array[Node] = $PickableSpawnPoints.get_children()
@onready var buturuga_spawn_points: Array[Node] = $ButurugaSpawnPoints.get_children()

@onready var cat_spawn_timer: Timer = $CatSpawnTimer
@onready var cat_spawns: Array[Node] = $CatSpawns.get_children()
@onready var cats: Node = $Cats

@onready var soup: Soup = $Soup
@onready var game_over_screen: TextureRect = %GameOverScreen
@onready var restart_game_btn: Button = %RestartGameBtn

var survival_time: float = 0.0
var is_game_active: bool = true
@onready var survived_label: Label = %SurvivedLabel

const CAT = preload("uid://bt8rvbp8bgh8w")

signal restart_requested()

func _ready() -> void:
	_spawn_rats()
	
	if multiplayer.is_server():
		item_spawn_timer.timeout.connect(_on_spawn_item)
		item_spawn_timer.start()
		buturuga_spawn_timer.timeout.connect(_on_spawn_buturuga)
		buturuga_spawn_timer.start()
		cat_spawn_timer.timeout.connect(_on_cat_spawn_timer)
		_start_random_cat_timer()
		
		if soup:
			soup.soup_ruined.connect(_on_soup_ruined)


func _process(delta: float) -> void:
	if multiplayer.is_server() and is_game_active:
		survival_time += delta

func _on_soup_ruined() -> void:
	if multiplayer.is_server():
		is_game_active = false
		_show_game_over.rpc(int(survival_time))


@rpc("authority", "call_local", "reliable")
func _show_game_over(time: int) -> void:
	item_spawn_timer.stop()
	buturuga_spawn_timer.stop()
	game_over_screen.show()
	survived_label.text = "you survived for %s seconds" % int(time)
	if multiplayer.is_server():
		restart_game_btn.show()

func _on_restart_game_btn_pressed() -> void:
	if multiplayer.is_server():
		restart_requested.emit()

func _start_random_cat_timer() -> void:
	cat_spawn_timer.wait_time = randf_range(30.0, 45.0)
	cat_spawn_timer.start()

func _on_cat_spawn_timer() -> void:
	if not multiplayer.is_server(): return
	print("spawned cat")
	var spawn_point = cat_spawns.pick_random()
	var new_cat = CAT.instantiate() as Cat
	new_cat.position = spawn_point.position
	cats.add_child(new_cat, true)
	new_cat.setup_direction(soup.global_position)
	_start_random_cat_timer()


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


func _on_spawn_buturuga() -> void:
	if not multiplayer.is_server():
		return    
	var available_points = []
	for spawn_point in buturuga_spawn_points:
		if not _is_log_position_occupied(spawn_point.position):
			available_points.append(spawn_point)
			
	if available_points.is_empty():
		print("buturugi full")
		return
		
	var spawn_point = available_points.pick_random()
	var new_log = BUTURUGA_RELAXATOARE.instantiate() as ButuragaRelaxatoare
	new_log.position = spawn_point.position
	buturugi.add_child(new_log, true)


func _is_log_position_occupied(pos: Vector2) -> bool:
	var occupation_threshold = 20.0
	
	for log_node in buturugi.get_children():
		if log_node is ButuragaRelaxatoare:
			if log_node.position.distance_to(pos) < occupation_threshold:
				return true
	return false
