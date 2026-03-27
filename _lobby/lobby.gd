extends Control


@onready var lobby_container: VBoxContainer = $LobbyContainer
const LOBBY_ITEM = preload("uid://hb5tkjoxt83j")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.peer_joined.connect(_on_peer_joined)


func _on_peer_joined(id: int) -> void:
	var new_item = LOBBY_ITEM.instantiate() as LobbyItem
	var peer_name = NetworkManager.peers.get(id, 1)
	new_item.setup(peer_name)
	
	lobby_container.add_child(new_item, true)
	
