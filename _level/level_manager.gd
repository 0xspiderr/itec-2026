class_name LevelManager extends Node2D


const RAT = preload("uid://do03p4467dnyq")
@onready var players: Node = $Players


func _ready() -> void:
	_spawn_rat()


func _spawn_rat() -> void:
	if not multiplayer.is_server():
		return
	
	var new_rat = RAT.instantiate() as RatController
	players.add_child(new_rat)
