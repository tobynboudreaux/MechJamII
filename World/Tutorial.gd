extends Control

onready var backButton = $TutColorRect/TutVBoxContainer/TutBackButton

func _ready():
	backButton.grab_focus()
	
func _on_TutBackButton_pressed():
	get_parent().handle_level_changed("menu")
