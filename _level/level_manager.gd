class_name LevelManager extends Node2D


const RAT = preload("uid://do03p4467dnyq")
@onready var players: Node = $Players
@onready var spawn_points: Node = $SpawnPoints


func _ready() -> void:
	_spawn_rats()


func _spawn_rats() -> void:
	if not multiplayer.is_server():
		return
	
	var spawns = spawn_points.get_children()
	for id in NetworkManager.peers:
		var new_rat = RAT.instantiate() as RatController
		var spawn_point = spawns.pop_front()
		new_rat.position = spawn_point.position
		new_rat.name = str(id) 
		new_rat.player_id = id
		players.add_child(new_rat, true)
