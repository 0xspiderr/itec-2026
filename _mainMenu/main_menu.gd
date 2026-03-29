extends Control

@onready var ip_addres: LineEdit = %IPAddres
@onready var name_player: LineEdit = %Name
@onready var connect_button: Button = %Connect
@onready var host_button: Button = %HostBtn
@onready var menu: VBoxContainer = %menuContainer
@onready var error: CenterContainer = %CenterContainer
@onready var help_menu: VBoxContainer = %HelpMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ip_addres.text_changed.connect(_check_fields)
	name_player.text_changed.connect(_check_fields)
	connect_button.disabled = true
	host_button.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _check_fields(_new_text: String = "") -> void:
	if ip_addres.text.is_empty() or name_player.text.is_empty():
		connect_button.disabled = true
	else:
		connect_button.disabled = false
	
	if not name_player.text.is_empty():
		host_button.disabled = false
	else:
		host_button.disabled = true
		

func _input(event: InputEvent) -> void:
	if event.is_pressed() and error.visible:
		menu.show()
		error.hide()

func _on_host_btn_pressed() -> void:
	NetworkManager.peer_name = name_player.text
	NetworkManager.create_host()


func _on_connect_btn_pressed() -> void:
	if ip_addres.text.is_valid_ip_address():
		NetworkManager.peer_name = name_player.text
		NetworkManager.create_client(ip_addres.text)
	else:
		menu.hide()
		error.show()

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://_start_menu/startScene.tscn")


func _on_help_button_pressed() -> void:
	menu.hide()
	help_menu.show()
	

func _on_back_help_button_pressed() -> void:
	menu.show()
	help_menu.hide()
