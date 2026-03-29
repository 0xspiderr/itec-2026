class_name Lobby extends Control


signal start_level()

@onready var lobby_container: VBoxContainer = %LobbyContainer
@onready var start_btn: Button = %StartBtn

const LOBBY_ITEM = preload("uid://hb5tkjoxt83j")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		start_btn.visible = true
	NetworkManager.update_lobby_ui.connect(_on_lobby_ui_update)
	_on_lobby_ui_update()
	multiplayer.server_disconnected.connect(_on_server_left)


func _on_lobby_ui_update() -> void:
	_remove_lobby_items()
	await get_tree().process_frame
	for id in NetworkManager.peers:
		var peer_name = NetworkManager.peers.get(id, 1)
		var new_item = LOBBY_ITEM.instantiate() as LobbyItem
		new_item.setup(peer_name)
		print(id)
		lobby_container.add_child(new_item, true)

func _remove_lobby_items() -> void:
	for item in lobby_container.get_children():
		item.queue_free()


func _on_start_btn_pressed() -> void:
	if not multiplayer.is_server():
		return
	start_level.emit() # called in the game parent scene


func _on_back_btn_pressed() -> void:
	NetworkManager.remove_multiplayer_peer()
	get_tree().call_deferred("change_scene_to_file", "res://_mainMenu/mainMenu.tscn")

func _on_server_left() -> void:
	NetworkManager.remove_multiplayer_peer()
	NetworkManager.peers.clear()
	NetworkManager.return_to_menu()
