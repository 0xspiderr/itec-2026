extends Control

@onready var settings: Control = $Settings

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://_mainMenu/mainMenu.tscn")


func _on_settings_btn_pressed() -> void:
	settings.visible = true


func _on_quit_btn_pressed() -> void:
	get_tree().quit()
