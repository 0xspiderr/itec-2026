class_name Soup extends Node2D

@export var starting_time: float = 60.0
@export var soup_time: float
var is_game_over: bool = false
var ingredients: Array[String] = []

const ITEM_TIME_VALUES: Dictionary = {
	"winter berries": 5.0,
	"dried barley": 10.0,
	"mushroom": 15.0,
	"wild leeks": 8.0
}


func _ready() -> void:
	soup_time = starting_time


func _process(delta: float) -> void:
	if not multiplayer.is_server() or is_game_over:
		return
	
	soup_time -= delta
	
	if soup_time <= 0.0:
		soup_time = 0.0
		is_game_over = true
		_trigger_game_over.rpc()


func server_receive_ingredient(player: RatController, item_name: String) -> void:
	if not multiplayer.is_server() or is_game_over: 
		return
	
	ingredients.append(item_name)
	
	var time_added = ITEM_TIME_VALUES.get(item_name, 5.0)
	soup_time += time_added
	
	print("soup received: ", item_name, " added: ", time_added, "s total: ", soup_time, "s")
	
	_sync_soup_data.rpc(ingredients)


@rpc("authority", "call_local", "reliable")
func _sync_soup_data(synced_ingredients: Array) -> void:
	ingredients = synced_ingredients
	# Visuals: Play a happy "splash" or "bubble" animation here

@rpc("authority", "call_local", "reliable")
func _trigger_game_over() -> void:
	is_game_over = true
	print("game over")
	
