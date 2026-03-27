extends MarginContainer

@onready var ip_addres: LineEdit = $menuContainer/IPAddres
@onready var name_player: LineEdit = $menuContainer/Name
@onready var connect: Button = $menuContainer/Connect
@onready var menu: VBoxContainer = $menuContainer
@onready var error: CenterContainer = $CenterContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ip_addres.text_changed.connect(_check_fields)
	name_player.text_changed.connect(_check_fields)
	connect.disabled = true
	connect.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _check_fields(new_text: String = "") -> void:
	if ip_addres.text.is_empty() or name_player.text.is_empty():
		connect.disabled = true
	else:
		connect.disabled = false

func _on_button_pressed() -> void:
	if ip_addres.text.is_valid_ip_address():
		print("try_connect")
	else:
		menu.hide()
		error.show()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and error.visible:
		menu.show()
		error.hide()
