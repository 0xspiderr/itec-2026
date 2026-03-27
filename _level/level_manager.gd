class_name LevelManager extends Node2D


@onready var lobby: Lobby = %Lobby
const LEVEL_1 = preload("uid://7tacau4f3hs6")


func _ready() -> void:
	lobby.start_level.connect(_on_start_level)


func _on_start_level() -> void:
	var new_level = LEVEL_1.instantiate()
	add_child(new_level, true)
