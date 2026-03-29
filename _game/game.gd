class_name Game extends Node2D


@onready var level_holder: Node = $LevelHolder
@onready var lobby: Lobby = %Lobby
const LEVEL_1 = preload("uid://7tacau4f3hs6")
@onready var settings: Control = $CanvasLayer/Settings


func _ready() -> void:
	lobby.start_level.connect(_on_start_level)


func _remove_old_level() -> void:
	for child in level_holder.get_children():
		child.queue_free()


func _on_start_level() -> void:
	if not multiplayer.is_server():
		return
	
	_remove_old_level()
	await get_tree().process_frame
	
	var new_level = LEVEL_1.instantiate()
	new_level.restart_requested.connect(_on_start_level)
	AudioServer.set_bus_mute(0, false)
	level_holder.add_child(new_level, true)
	_hide_ui.rpc()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		settings.visible = !settings.visible

@rpc("authority", "call_local", "reliable")
func _hide_ui() -> void:
	lobby.hide()
