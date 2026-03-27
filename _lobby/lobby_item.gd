class_name LobbyItem extends HBoxContainer

@onready var name_label: Label = $NameLabel


func setup(peer_name: String) -> void:
	await ready
	name_label.text = peer_name
	pass
