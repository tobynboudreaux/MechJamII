extends Control
	
func _on_Button_pressed():
	get_parent().handle_level_changed("menu")
