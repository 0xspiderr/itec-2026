extends Node


const DEFAULT_IP: String = "localhost"
const PORT: int = 9000
var peers: Dictionary = {}
var peer_name: String = "default"


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if not OS.is_debug_build():
		return
	
	if "--server" in OS.get_cmdline_args():
		create_host()
	
	if "--client" in OS.get_cmdline_args():
		create_client(DEFAULT_IP)


func create_host():
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT)
	
	if err:
		return err
	
	multiplayer.multiplayer_peer = peer
	peers[1] = peer_name
	
	print("created host")


func create_client(ip_addr: String):
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip_addr, PORT)
	
	if err:
		printerr("couldn't create client")
		return err
	
	multiplayer.multiplayer_peer = peer
	print("created client")


func _on_player_connected(id: int) -> void:
	_register_peer.rpc_id(id,)


@rpc("any_peer","reliable")
func _register_peer() -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	peers[peer_id] = peer_name
	#print(peers)


func _on_player_disconnected(id: int) -> void:
	peers.erase(id)
	#print(peers)


func _on_connected_to_server() -> void:
	var peer_id: int = multiplayer.get_unique_id()
	peers[peer_id] = peer_name
	#print(peers)
	

func _on_connected_fail() -> void:
	remove_multiplayer_peer()


func _on_server_disconnected() -> void:
	remove_multiplayer_peer()
	peers.clear()


func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	peers.clear()
